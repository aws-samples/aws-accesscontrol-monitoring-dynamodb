# -----------------------------------------------------------
# setup permissions to allow Cloudtrail to write to Cloudwatch
# -----------------------------------------------------------
resource "aws_iam_role" "cloudtrail_cloudwatch" {
  name = "cloudtrail_cloudwatch"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch" {
  name = "cloudtrail_cloudwatch"
  role = "${aws_iam_role.cloudtrail_cloudwatch.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailCreateLogStream",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:CreateLogGroup",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:${aws_cloudwatch_log_group.dynamodb_cloudtrail.id}:log-stream:*"
            ]
        }
    ]
}
EOF
}

# -----------------------------------------------------------
# setup Cloudwatch logs to receive Cloudtrail events
# -----------------------------------------------------------

resource "aws_cloudwatch_log_group" "dynamodb_cloudtrail" {
  name = "dynamodb_cloudtrail"
  retention_in_days = 7
}

# Output the CloudWatch Logs group ARN
output "cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.dynamodb_cloudtrail.arn
}

# -----------------------------------------------------------
# Enable Cloudtrail for DynamoDB
# -----------------------------------------------------------

resource "aws_cloudtrail" "dynamodb_cloudtrail" {
  depends_on = [aws_s3_bucket_policy.dynamodb_cloudtrail]

  name                          = "dynamodb_cloudtrail"
  s3_bucket_name                = aws_s3_bucket.dynamodb_cloudtrail.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = false
  is_multi_region_trail         = false
  enable_logging                = true
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.dynamodb_cloudtrail.arn}:*" # CloudTrail requires the Log Stream wildcard
  cloud_watch_logs_role_arn     = "${aws_iam_role.cloudtrail_cloudwatch.arn}"

  advanced_event_selector {
    name = "FindDeletedItems"
    field_selector {
        field = "eventCategory"
        equals = [
          "Data"
        ]
    }
    field_selector {
        field = "resources.type"
        equals = [
          "AWS::DynamoDB::Table"
        ]
    }
    field_selector {
        field = "resources.ARN"
        equals = [
          "${var.aws_dynamodb_arn}"
        ]
    }
    field_selector {
        field = "eventName"
        equals = [
          "DeleteItem"
        ]
    }
  }
}
# -----------------------------------------------------------
# Creating S3 bucket
# -----------------------------------------------------------

resource "aws_s3_bucket" "dynamodb_cloudtrail" {
  bucket        = "dynamodb-ct-${var.aws_account_id}"
  force_destroy = true
}

data "aws_iam_policy_document" "dynamodb_cloudtrail" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.dynamodb_cloudtrail.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/dynamodb_cloudtrail"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.dynamodb_cloudtrail.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/dynamodb_cloudtrail"]
    }
  }
}

resource "aws_s3_bucket_policy" "dynamodb_cloudtrail" {
  bucket = aws_s3_bucket.dynamodb_cloudtrail.id
  policy = data.aws_iam_policy_document.dynamodb_cloudtrail.json
}

resource "aws_cloudwatch_log_metric_filter" "DBDeleteItemCount" {
  name           = "DBDeleteItemCount"
  pattern        = ""
  log_group_name = aws_cloudwatch_log_group.dynamodb_cloudtrail.name

  metric_transformation {
    name      = "EventCount"
    namespace = "dynamodb_cloudtrail_cw"
    value     = "1"
  }
}


data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}


