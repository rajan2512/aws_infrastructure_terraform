terraform {
   backend "s3" {
    encrypt = true
    bucket = "launchpad-state-file"
    # dynamodb_table = "terraform-state-lock-dynamo"
    key = "key"
    region = "eu-west-1"
  }
}
