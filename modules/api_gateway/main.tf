locals {
  rest_api_id        = aws_api_gateway_rest_api.rest-api.id
  object_resource_id = aws_api_gateway_resource.object-resource.id
}
resource "aws_api_gateway_rest_api" "rest-api" {
  api_key_source               = var.api_key_source
  binary_media_types           = var.binary_media_types
  description                  = var.rest_api_description
  disable_execute_api_endpoint = var.disable_execute_api_endpoint

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  minimum_compression_size = var.minimum_compression_size
  name                     = var.rest_api_name
}

## api_gateway_resource
resource "aws_api_gateway_resource" "folder-resource" {
  rest_api_id = local.rest_api_id
  parent_id   = aws_api_gateway_rest_api.rest-api.root_resource_id
  path_part   = var.path_part_folder
}
resource "aws_api_gateway_resource" "object-resource" {
  rest_api_id = local.rest_api_id
  parent_id   = aws_api_gateway_resource.folder-resource.id
  path_part   = var.path_part_object
}



resource "aws_api_gateway_method" "api-gateway-method" {
  api_key_required = var.api_key_required
  authorization    = var.authorization
  http_method      = var.http_method

  request_parameters = var.method_request_parameters

  resource_id = local.object_resource_id
  rest_api_id = local.rest_api_id


}

resource "aws_api_gateway_integration" "api-gateway-integration" {
  depends_on = [
    aws_api_gateway_method.api-gateway-method, aws_api_gateway_resource.object-resource,
    aws_api_gateway_resource.folder-resource, aws_api_gateway_rest_api.rest-api
  ]
  connection_type = var.integration_connection_type

  credentials             = var.credentials_role_arn
  http_method             = var.http_method
  integration_http_method = var.integration_http_method
  passthrough_behavior    = var.passthrough_behavior
  request_parameters      = var.integration_request_parameters
  resource_id             = local.object_resource_id
  rest_api_id             = local.rest_api_id
  timeout_milliseconds    = var.integration_timeout_milliseconds
  type                    = var.integration_type
  uri                     = var.integration_uri
}

resource "aws_api_gateway_method_response" "api-gateway-method-response" {
  depends_on  = [aws_api_gateway_integration.api-gateway-integration]
  http_method = var.http_method
  resource_id = local.object_resource_id

  response_models = var.response_models

  rest_api_id = local.rest_api_id
  status_code = var.response_status_code
}
resource "aws_api_gateway_integration_response" "api-gateway-integration-response" {
  depends_on  = [aws_api_gateway_integration.api-gateway-integration]
  http_method = var.http_method
  resource_id = local.object_resource_id
  rest_api_id = local.rest_api_id
  status_code = var.response_status_code
}
resource "aws_api_gateway_deployment" "api-gateway-deployment" {
  depends_on = [
    aws_api_gateway_method.api-gateway-method,
    aws_api_gateway_integration.api-gateway-integration,
  ]

  rest_api_id = local.rest_api_id

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_stage" "api-gateway-stage" {
  depends_on = [
    aws_api_gateway_deployment.api-gateway-deployment
  ]

  cache_cluster_enabled = var.cache_cluster_enabled
  deployment_id         = aws_api_gateway_deployment.api-gateway-deployment.id
  rest_api_id           = local.rest_api_id
  stage_name            = var.stage_name
  xray_tracing_enabled  = var.xray_tracing_enabled
}

resource "aws_api_gateway_domain_name" "custom-domain-name" {
  domain_name              = var.domain_name
  regional_certificate_arn = var.ssl_certificate_arn

  endpoint_configuration {
    types = var.endpoint_configuration_type
  }
}

# resource "aws_route53_record" "custom-domain-name" {
#   name    = aws_api_gateway_domain_name.custom-domain-name.domain_name
#   type    = var.record_type
#   zone_id = var.route53_zone_id

#   alias {
#     evaluate_target_health = var.evaluate_target_health
#     name                   = aws_api_gateway_domain_name.custom-domain-name.regional_domain_name
#     zone_id                = aws_api_gateway_domain_name.custom-domain-name.regional_zone_id
#   }
# }

## This module is used to create a custom domain name for the API Gateway
module "create_api_gateway_route53_record" {
  source = "../route_53"
  route53_records = {
    "${var.domain_name}" = {
      name    = aws_api_gateway_domain_name.custom-domain-name.domain_name
      type    = var.record_type
      zone_id = var.route53_zone_id
      alias = [{
        evaluate_target_health = var.evaluate_target_health
        name                   = aws_api_gateway_domain_name.custom-domain-name.regional_domain_name
        zone_id                = aws_api_gateway_domain_name.custom-domain-name.regional_zone_id
      }]
    }
  }

}

resource "aws_api_gateway_base_path_mapping" "base-path-mapping" {
  api_id      = aws_api_gateway_rest_api.rest-api.id
  stage_name  = aws_api_gateway_stage.api-gateway-stage.stage_name
  domain_name = aws_api_gateway_domain_name.custom-domain-name.domain_name
}

resource "aws_api_gateway_method_settings" "api-gateway-method-settings" {
  rest_api_id = aws_api_gateway_rest_api.rest-api.id
  stage_name  = aws_api_gateway_stage.api-gateway-stage.stage_name
  method_path = "*/*"
  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    metrics_enabled    = true
  }
}
