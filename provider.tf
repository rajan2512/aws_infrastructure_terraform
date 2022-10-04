terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
# provider "aws" {
#   region = local.region
# }
# provider "aws" {
#   region = "us-east-1"
#   alias  = "useast1"
# }

provider "aws" {
  region = "eu-west-1"
  alias  = "west"
}
