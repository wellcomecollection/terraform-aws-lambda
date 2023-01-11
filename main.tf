resource "aws_lambda_function" "main" {
  function_name = var.name
  role          = aws_iam_role.lambda.arn

  tags = var.lambda_tags

  // These are likely to be mutually exclusive, which is the rationale for using all of them at once
  // Unfortunately lifecycle config can't be parameterised, and consumers of the module might be using
  // any of these 3 methods of specifying the Lambda source
  lifecycle {
    ignore_changes = [
      filename,
      image_uri,
      s3_object_version
    ]
  }

  // All parameters below are passed through directly
  architectures           = var.architectures
  code_signing_config_arn = var.code_signing_config_arn
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_config == null ? [] : [{}]
    content {
      target_arn = var.dead_letter_config.target_arn
    }
  }
  description = var.description
  dynamic "environment" {
    for_each = var.environment == null ? [] : [{}]
    content {
      variables = var.environment.variables
    }
  }
  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage == null ? [] : [{}]
    content {
      size = var.ephemeral_storage.size
    }
  }
  dynamic "file_system_config" {
    for_each = var.file_system_config == null ? [] : [{}]
    content {
      arn              = var.file_system_config.arn
      local_mount_path = var.file_system_config.local_mount_path
    }
  }
  filename = var.filename
  handler  = var.handler
  dynamic "image_config" {
    for_each = var.image_config == null ? [] : [{}]
    content {
      command           = var.image_config.command
      entry_point       = var.image_config.entry_point
      working_directory = var.image_config.working_directory
    }
  }
  image_uri                      = var.image_uri
  kms_key_arn                    = var.kms_key_arn
  layers                         = var.layers
  memory_size                    = var.memory_size
  package_type                   = var.package_type
  publish                        = var.publish
  reserved_concurrent_executions = var.reserved_concurrent_executions
  runtime                        = var.runtime
  s3_bucket                      = var.s3_bucket
  s3_key                         = var.s3_key
  s3_object_version              = var.s3_object_version
  source_code_hash               = var.source_code_hash
  dynamic "snap_start" {
    for_each = var.snap_start == null ? [] : [{}]
    content {
      apply_on = var.snap_start.apply_on
    }
  }
  timeout = var.timeout
  dynamic "tracing_config" {
    for_each = var.tracing_config == null ? [] : [{}]
    content {
      mode = var.tracing_config.mode
    }
  }
  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [{}]
    content {
      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "lambda-role-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_logging" {
  policy_arn = aws_iam_policy.lambda_logging.arn
  role       = aws_iam_role.lambda.name
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda-logging-${var.name}"
  description = "Allow the ${var.name} Lambda to send logs to CloudWatch"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

// https://docs.aws.amazon.com/lambda/latest/operatorguide/access-logs.html
data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup"]
    resources = ["arn:aws:logs:region:${data.aws_caller_identity.account.account_id}:*"]
  }
  statement {
    effect  = "Allow"
    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [
      "${aws_cloudwatch_log_group.lambda.arn}:*"
    ]
  }
}

data "aws_caller_identity" "account" {}
