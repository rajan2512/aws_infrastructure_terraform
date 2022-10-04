variable "rest_api_name" {
  description = "The name of the REST API"
  type        = string
}
variable "credentials_role_arn" {
  description = "The ARN of the role to use for the integration"
  type        = string
}

variable "api_key_required" {
  description = "Whether or not to require an API key for the method"
  type        = string
}
variable "authorization" {
  description = "The authorization type for the method"
  type        = string
}
variable "http_method" {
  description = "The HTTP method for the method"
  type        = string
}
variable "method_request_parameters" {
  description = "The request parameters for the method"
  type        = map(string)

}
variable "integration_request_parameters" {
  description = "The request parameters for the integration"
  type        = map(string)
}

variable "integration_http_method" {
  description = "The HTTP method for the integration"
  type        = string
}
variable "passthrough_behavior" {
  description = "The passthrough behavior for the integration"
  type        = string
}

variable "integration_timeout_milliseconds" {
  description = "The timeout for the integration"
  type        = string
}
variable "integration_type" {
  description = "The type of the integration"
  type        = string
}
variable "integration_uri" {
  description = "The URI for the integration"
  type        = string
}

variable "integration_connection_type" {
  description = "The connection type for the integration"
  type        = string
}

variable "response_models" {
  description = "The response models for the method"
  type        = map(string)
}

variable "response_status_code" {
  description = "The status code for the method response"
  type        = string
}

variable "cache_cluster_enabled" {
  description = "Whether or not to enable a cache cluster for the stage"
  type        = string
}
variable "stage_name" {
  description = "The name of the stage"
  type        = string

}
variable "xray_tracing_enabled" {
  description = "Whether or not to enable X-Ray tracing for the stage"
  type        = string

}

variable "minimum_compression_size" {
  description = "The minimum compression size for the stage"
  type        = number
  default     = -1
}

variable "api_key_source" {
  description = "The source of the API key for the stage"
  type        = string
  default     = "HEADER"
}
variable "binary_media_types" {
  description = "The binary media types for the stage"
  type        = list(string)
  default     = []
}
variable "rest_api_description" {
  description = "The description of the REST API"
  type        = string
  default     = ""
}

variable "disable_execute_api_endpoint" {
  description = "Whether or not to disable the execute API endpoint for the stage"
  type        = string
  default     = "false"
}

variable "path_part_folder" {
  description = "The path part for the folder resource"
  type        = string

}

variable "path_part_object" {
  description = "The path part for the file resource"
  type        = string
}

variable "record_type" {
  description = "The record type for the file resource"
  type        = string

}
variable "route53_zone_id" {
  description = "The zone ID for the file resource"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the file resource"
  type        = string
}
variable "ssl_certificate_arn" {
  description = "The SSL certificate ARN for the file resource"
  type        = string
}
variable "endpoint_configuration_type" {
  description = "The endpoint configuration types for the file resource"
  type        = list(string)
}
variable "evaluate_target_health" {
  description = "Whether or not to evaluate target health for the file resource"
  type        = string
}
