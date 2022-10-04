locals {
  lambda_functions = ["CreateThumbnail",
    "CreateMobileImage",
  "CreateWebImage"]
  sqs_queue_names = ["ThumbnailQueue", "MobileImageQueue", "WebImageQueue"]

  main_bucket_name    = "resize-app-images-bucket${local.name_sufix}"
  replica_bucket_name = "resize-app-images-bucket-replica${local.name_sufix}"
  bucket_name_in_use  = local.enviroment == "failover" ? local.replica_bucket_name : local.main_bucket_name
  ## Select main S3 bucket based on infrastructure state. If it's failover use replica bucket as
  ## main bucket
  s3_main_bucket_arn              = local.enviroment == "failover" ? local.s3_replica_bucket_arn : "arn:aws:s3:::${local.main_bucket_name}"
  s3_replica_bucket_arn           = "arn:aws:s3:::${local.replica_bucket_name}"
  api_domain_name                 = "${local.enviroment}.launchpadteam.quest"
  api_gateway_policy_name         = "S3UploadPolicy${local.name_sufix}"
  api_gateway_role_name           = "UploadToS3AccessRole${local.name_sufix}"
  sns_topic_name                  = "resize-app-image-upload-topic${local.name_sufix}"
  replication_role_name           = "S3ReplicationRole${local.name_sufix}"
  replication_policy_name         = "S3ReplicationPolicy${local.name_sufix}"
  replication_rule_name           = "S3ReplicationRule${local.name_sufix}"
  lambda_role_name                = "LambdaRole${local.name_sufix}"
  lambda_policy_name              = "LambdaPolicy${local.name_sufix}"
  ssl_certificate_id              = local.enviroment == "failover" ? "9a011615-caf2-406e-af78-fb753c55e4cb" : "d676e712-6896-4423-8924-a1ffc99ecd4b"
  api_gateway_ssl_certificate_arn = "arn:aws:acm:${local.region}:312812643817:certificate/d676e712-6896-4423-8924-a1ffc99ecd4b"

}

## Create main S3 bucket
module "s3_images_bucket" {
  depends_on = [
    module.sns_image_upload_topic,
  ]

  count               = local.failover ? 0 : 1
  source              = "./modules/s3_bucket"
  main_bucket_name    = local.main_bucket_name
  versioning          = "Enabled"
  acl                 = "private"
  block_public_access = true
}

## Create S3 replication bucket
module "s3_replica" {
  count = local.failover ? 0 : 1
  providers = {
    aws = aws.useast1
  }
  source              = "./modules/s3_bucket"
  main_bucket_name    = local.replica_bucket_name
  versioning          = "Enabled"
  acl                 = "private"
  block_public_access = true
}


## Create S3 bucket replication role and attach needed policie
module "s3_bucket_policy" {
  count = local.failover ? 0 : 1
  depends_on = [
    module.s3_images_bucket, module.s3_replica
  ]
  source                  = "./modules/s3_bucket_policy"
  replication_role_name   = local.replication_role_name
  replication_policy_name = local.replication_policy_name
  main_bucket_arn         = module.s3_images_bucket[0].bucket_arn
  replica_bucket_arn      = module.s3_replica[0].bucket_arn


}

# Create S3 replication configuration

module "s3_bucket_replica_configuration" {
  count = local.failover ? 0 : 1
  depends_on = [
    module.s3_replica, module.s3_images_bucket, module.s3_bucket_policy
  ]
  source                    = "./modules/s3_bucket_replica_configuration"
  replication_rule_status   = "Enabled"
  replication_rule_name     = local.replication_rule_name
  delete_marker_replication = "Disabled"
  filter_prefix             = ""
  storage_class             = "STANDARD"
  main_bucket_id            = module.s3_images_bucket[0].bucket_id
  main_bucket_arn           = module.s3_images_bucket[0].bucket_arn
  replication_role_arn      = module.s3_bucket_policy[0].replication_role_arn
  replica_bucket_arn        = module.s3_replica[0].bucket_arn


}

## Create SNS topic for image upload notifications
## Assign replica bucket if it's failover
module "sns_image_upload_topic" {

  source         = "./modules/sns"
  s3_bucket_id   = local.bucket_name_in_use
  sns_topic_name = local.sns_topic_name
  s3_bucket_arn  = local.s3_main_bucket_arn
}

## Create SNS role for S3 bucket notifications
module "sns_image_upload_topic_policy" {
  depends_on = [
    module.s3_images_bucket
  ]
  source                     = "./modules/sns_topic_policy"
  sns_topic_name             = local.sns_topic_name
  s3_bucket_arn              = local.s3_main_bucket_arn
  sns_resize_image_topic_arn = module.sns_image_upload_topic.sns_topic_arn
}
module "s3_bucket_notification" {
  depends_on = [
    module.sns_image_upload_topic_policy
  ]
  source                     = "./modules/s3_bucket_notification"
  s3_bucket_id               = module.s3_images_bucket[0].bucket_id
  sns_resize_image_topic_arn = module.sns_image_upload_topic.sns_topic_arn
}

## Create SQS queues for Lambda functions triggering
module "sqs_lambda_triggers" {
  depends_on = [
    module.s3_images_bucket, module.s3_replica, module.sns_image_upload_topic
  ]
  source          = "./modules/sqs_queue"
  sns_topic_arn   = module.sns_image_upload_topic.sns_topic_arn
  sqs_queue_names = toset(local.sqs_queue_names)
  s3_bucket_name  = local.bucket_name_in_use
  sns_topic_name  = local.sns_topic_name
  name_sufix      = local.name_sufix
}

## Subscribe SNS topic to SQS queues
module "sns_topic_subscription" {
  source = "./modules/sns_topic_subscription"
  depends_on = [
    module.sns_image_upload_topic, module.sns_image_upload_topic_policy
  ]
  sns_subscription_protocol = "sqs"
  sns_topic_arn             = module.sns_image_upload_topic.sns_topic_arn
  lambda_queue_arns         = tomap(module.sqs_lambda_triggers.arns)
}

## Create API Gateway role and attach needed policies (S3PutObject and CloudWatch)
module "api_gateway_policy" {
  source                  = "./modules/api_gateway_policy"
  api_gateway_policy_name = local.api_gateway_policy_name
  api_gateway_role_name   = local.api_gateway_role_name
  cloud_watch_policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
  api_gateway_action      = "s3:PutObject"
  s3_bucket_arn           = local.s3_main_bucket_arn
}

## Create API Gateway.
## API Gateway will be used to upload images to S3 bucket.
module "api_gateway" {
  source = "./modules/api_gateway"
  depends_on = [
    module.api_gateway_policy
  ]
  disable_execute_api_endpoint     = "false"
  api_key_required                 = "false"
  rest_api_name                    = "Resize-App-API"
  authorization                    = "NONE"
  http_method                      = "POST"
  path_part_folder                 = "{folder}"
  path_part_object                 = "{object}"
  integration_http_method          = "PUT"
  passthrough_behavior             = "WHEN_NO_MATCH"
  integration_timeout_milliseconds = "29000"
  integration_type                 = "AWS"
  integration_uri                  = "arn:aws:apigateway:${local.region}:s3:path/{bucket}/{key}"
  integration_connection_type      = "INTERNET"
  response_status_code             = "200"
  stage_name                       = "v1"
  xray_tracing_enabled             = "false"
  cache_cluster_enabled            = "false"
  binary_media_types               = ["*/*"]
  rest_api_description             = "API To Resize Image"
  credentials_role_arn             = module.api_gateway_policy.api_gateway_role_arn
  domain_name                      = local.api_domain_name
  ssl_certificate_arn              = local.api_gateway_ssl_certificate_arn
  endpoint_configuration_type      = ["REGIONAL"]
  record_type                      = "A"
  route53_zone_id                  = local.route53_zone_id
  evaluate_target_health           = "true"
  method_request_parameters = {
    "method.request.path.folder" = "true"
    "method.request.path.object" = "true"
  }
  integration_request_parameters = {
    "integration.request.path.bucket" = "method.request.path.folder"
    "integration.request.path.key"    = "method.request.path.object"
  }
  response_models = {
    "application/json" = "Empty"
  }
}

## Create Lambda role and attach needed policies (S3, SQS, CloudWatch)
module "lambda_role_policy" {
  source                 = "./modules/lambda_policy"
  lambda_role_name       = local.lambda_role_name
  lambda_policy_name     = local.lambda_policy_name
  sqs_trigger_policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
  s3_artifact_bucket_arn = "arn:aws:s3:::${local.s3_artifact_bucket_name}"
  s3_bucket_arn          = local.s3_main_bucket_arn
}

## Create Lambda functions to resize images (small, medium, large).
## Lambda functions will be triggered by SQS queues when the image is uploaded
## to the S3 bucket.
## Resized images will be uploaded to S3 bucket.
module "resize_image_lambda_functions" {
  depends_on = [
    module.lambda_role_policy, module.sqs_lambda_triggers
  ]
  source          = "./modules/lambda_functions"
  for_each        = toset(local.lambda_functions)
  lambda_role_arn = module.lambda_role_policy.lambda_role_arn
  package_type    = "Zip"
  architectures   = ["x86_64"]
  runtime         = "python3.7"
  function_name   = "${each.value}${local.name_sufix}"
  handler         = "${each.value}.handler"
  s3_bucket       = local.s3_artifact_bucket_name
  s3_key          = "${each.value}.zip"
  timeout         = 60

}

## Attach SQS queues to Lambda functions to trigger them.
module "lambda_sqs_triggers" {

  depends_on = [
    module.resize_image_lambda_functions, module.sqs_lambda_triggers
  ]
  source                             = "./modules/lambda_events"
  count                              = length(tolist(local.lambda_functions))
  lambda_function_name               = "${local.lambda_functions[count.index]}${local.name_sufix}"
  sqs_queue_name                     = "${local.sqs_queue_names[count.index]}${local.name_sufix}"
  batch_size                         = "1"
  enabled                            = "true"
  maximum_batching_window_in_seconds = "0"
}
