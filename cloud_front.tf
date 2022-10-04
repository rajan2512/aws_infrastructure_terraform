## TODO:
## 1. Import LB DNS name from AWS
## 2. Create S3 log bucket
## 3. Add all the CF parameters to the modul


locals {
  failover_pipeline_name      = "failover"
  route53_zone_id             = "Z0142928239LP5NHQ0V1N"
  cloud_front_domain_prefix   = local.enviroment == "dev" ? "www." : ""
  cloud_front_domain          = "launchpadteam.quest"
  failover_function_name      = "FailoverFunction${local.name_sufix}"
  failure_sns_topic_name      = "WebAppDNSFailureNotification${local.name_sufix}"
  log_bucket                  = "launchpad-application-bucket.s3.amazonaws.com"
  failover_lambda_policy_name = "FailoverLambdaPolicy${local.name_sufix}"
  failover_lambda_role_name   = "FailoverLambdaRole${local.name_sufix}"
  failover_pipeline_arn       = "arn:aws:codepipeline:us-east-1:312812643817:${local.failover_pipeline_name}"
  sns_trigger_policy_arn      = "arn:aws:iam::aws:policy/AmazonSNSReadOnlyAccess"
  dns_alarm_name              = "WebAppDNSFailure${local.name_sufix}"
  cloud_front_waf_name        = "WebAppWAF${local.name_sufix}"
}

module "create_waf_cloud_front" {
  count  = local.failover ? 0 : 1
  source = "./modules/waf"
  providers = {
    aws = aws.useast1
  }
  waf_configurations = {
    "${local.cloud_front_waf_name}" : {
      scope : "CLOUDFRONT",
      cloudwatch_metrics_enabled = "true"
      metric_name                = local.cloud_front_waf_name
      sampled_requests_enabled   = "true"
      rule = [
        {
          name                       = "AWS-ManagedRulesPHPRuleSet"
          priority                   = 0
          cloudwatch_metrics_enabled = "true"
          vendor_name                = "AWS"
          metric_name                = "AWS-AWSManagedRulesPHPRuleSet"
          managed_rule_name          = "AWSManagedRulesPHPRuleSet"
          sampled_requests_enabled   = "true"
        },
        {
          name                       = "AWS-AWSManagedRulesAmazonIpReputationList"
          priority                   = "2"
          cloudwatch_metrics_enabled = "true"
          vendor_name                = "AWS"
          metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
          managed_rule_name          = "AWSManagedRulesAmazonIpReputationList"
          sampled_requests_enabled   = "true"
        },
        {
          name                       = "AWS-AWSManagedRulesAnonymousIpList"
          priority                   = "3"
          cloudwatch_metrics_enabled = "true"
          metric_name                = "AWS-AWSManagedRulesAnonymousIpList"
          sampled_requests_enabled   = "true"
          managed_rule_name          = "AWSManagedRulesAnonymousIpList"
          vendor_name                = "AWS"
        },
        {
          name                       = "AWS-AWSManagedRulesCommonRuleSet"
          priority                   = "4"
          cloudwatch_metrics_enabled = "true"
          metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
          sampled_requests_enabled   = "true"
          managed_rule_name          = "AWSManagedRulesCommonRuleSet"
          vendor_name                = "AWS"
        },
        {
          name                       = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
          priority                   = "5"
          cloudwatch_metrics_enabled = "true"
          metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
          sampled_requests_enabled   = "true"
          managed_rule_name          = "AWSManagedRulesKnownBadInputsRuleSet"
          vendor_name                = "AWS"
        },
        {
          name                       = "AWS-AWSManagedRulesLinuxRuleSet"
          priority                   = "1"
          cloudwatch_metrics_enabled = "true"
          metric_name                = "AWS-AWSManagedRulesLinuxRuleSet"
          sampled_requests_enabled   = "true"
          managed_rule_name          = "AWSManagedRulesLinuxRuleSet"
          vendor_name                = "AWS"
        }
      ],

    }
  }
}


module "create_cloud_front_distribution" {
  count = local.failover ? 0 : 1
  depends_on = [
    module.create_load_balancer
  ]
  providers = {
    aws = aws.useast1
  }
  source                         = "./modules/cloud_front"
  cloud_front_custom_domain_name = local.cloud_front_domain
  cloud_front_certificate_arn    = "arn:aws:acm:us-east-1:312812643817:certificate/776c83e3-1772-404f-9364-35077de18203"
  cloud_front_target             = local.load_balancer_dns_name
  cloud_front_log_bucket         = local.log_bucket
  # web_acl_id                     = module.create_waf_cloud_front.waf_acl_arn[0]
}

module "create_route53_record" {
  source = "./modules/route_53"
  count  = local.failover ? 0 : 1
  providers = {
    aws = aws.useast1
  }
  route53_records = {
    "${local.cloud_front_domain}" = {
      type                   = "A"
      name                   = local.cloud_front_domain
      evaluate_target_health = "true"
      zone_id                = local.route53_zone_id
      alias = toset([{
        name                   = module.create_cloud_front_distribution[0].domain_name
        zone_id                = module.create_cloud_front_distribution[0].hosted_zone_id
        evaluate_target_health = "true"
      }]),
    }
  }
}



module "create_cloud_front_health_check" {
  source = "./modules/route_53"
  count  = local.failover ? 0 : 1

  providers = {
    aws = aws.useast1
  }
  failure_topic_name = local.failure_sns_topic_name
  route53_health_checks = {
    "${local.cloud_front_domain}" = {
      type              = "HTTPS"
      resource_path     = "/"
      failure_threshold = "3"
      port              = "443"
      request_interval  = "30",
      alarm = {
        alarm_name                      = local.dns_alarm_name
        comparison_operator             = "LessThanThreshold"
        evaluation_periods              = "1"
        metric_name                     = "HealthCheckStatus"
        namespace                       = "AWS/Route53"
        period                          = "60"
        statistic                       = "Minimum"
        threshold                       = 1
        actions_enabled                 = "true"
        insufficient_data_health_status = "Healthy"
        cloudwatch_alarm_region         = "us-east-1"
      }

    }
  }
}

module "create_failover_lambda_role" {
  count = local.failover ? 0 : 1
  providers = {
    aws = aws.useast1
  }
  source                      = "./modules/lambda_failover_policy"
  failover_lambda_policy_name = local.failover_lambda_policy_name
  failover_lambda_role_name   = local.failover_lambda_role_name
  failover_pipeline_arn       = local.failover_pipeline_arn
  sns_trigger_policy_arn      = local.sns_trigger_policy_arn
  failover_function_name      = local.failover_function_name
  sns_topic_arn               = module.create_cloud_front_health_check[0].failure_sns_topic_arn
}

module "create_failover_lambda_function" {
  count  = local.failover ? 0 : 1
  source = "./modules/lambda_functions"
  providers = {
    aws = aws.useast1
  }

  lambda_role_arn = module.create_failover_lambda_role[0].failover_lambda_role
  package_type    = "Zip"
  architectures   = ["x86_64"]
  runtime         = "nodejs16.x"
  function_name   = local.failover_function_name
  handler         = "index.handler"
  s3_bucket       = local.s3_failover_artifact_bucket_name
  s3_key          = "failover.zip"
  timeout         = 60
  pipeline        = local.failover_pipeline_name


}
module "attach_alarm_sns_trigger" {
  count = local.failover ? 0 : 1
  providers = {
    aws = aws.useast1
  }

  source                    = "./modules/sns_topic_subscription"
  sns_topic_arn             = module.create_cloud_front_health_check[0].failure_sns_topic_arn
  sns_subscription_protocol = "lambda"
  lambda_queue_arns         = tomap({ key = module.create_failover_lambda_function[0].lambda_function_arn })

}
