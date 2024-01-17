variable "tags" {
  default = {
    "owner"   = "teamarunparag"
    "project" = "cloudtrail-test"
    "client"  = "anyone"
  }
}

variable "bucket_prefix" {
  default = "example-logs"
}

variable "trail_name" {
  default = "example-trail"
}

variable "aws_account_id" {}
variable "aws_region" {}
variable "aws_dynamodb_arn" {}

