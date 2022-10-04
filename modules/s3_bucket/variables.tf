variable "main_bucket_name" {
  type        = string
  description = "Name of the main bucket"
}

variable "versioning" {
  type        = string
  description = "Versioning of the bucket"
}

variable "block_public_access" {
  type        = bool
  description = "Block public access to the bucket"
}

variable "acl" {
  type        = string
  description = "ACL of the bucket"
}
