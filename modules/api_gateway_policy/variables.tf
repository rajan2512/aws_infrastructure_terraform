variable "api_gateway_policy_name" {
  description = "Name of the API Gateway policy"
  type        = string
}

variable "api_gateway_role_name" {
  description = "Name of the role to be created"
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  type        = string
}

variable "cloud_watch_policy_arn" {
  description = "ARN of the CloudWatch policy"
  type        = string
}

variable "api_gateway_action" {
  description = "The action that the API Gateway will have access to"
  type        = string
}

