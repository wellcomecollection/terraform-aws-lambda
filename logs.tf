resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.forward_logs_to_elastic ? 1 : 7
}

resource "aws_cloudwatch_log_subscription_filter" "kinesis" {
  for_each = var.forward_logs_to_elastic ? toset(["lambda-logs-to-kinesis"]) : toset([])

  name            = each.value
  log_group_name  = aws_cloudwatch_log_group.lambda.name
  destination_arn = data.aws_ssm_parameter.log_destination.value
  filter_pattern  = "" // An empty pattern matches all logs
}

data "aws_ssm_parameter" "log_destination" {
  name = "/logging/forwarder/destination_arn"
}

// This resource is constructed from this name:
// https://github.com/wellcomecollection/platform-infrastructure/blob/main/monitoring/terraform/modules/slack_alert_on_lambda_error/main.tf#L6
// and is defined here:
// https://github.com/wellcomecollection/platform-infrastructure/blob/main/monitoring/terraform/modules/slack_alert_lambda/topics.tf#L2
data "aws_sns_topic" "alarm_topic" {
  name = "${local.account_name}_lambda_error_alarm"
}

data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

locals {
  // The session issuer name will be something like "catalogue-developer" etc
  account_name = split("-", data.aws_iam_session_context.current.issuer_name)[0]
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors"{
  for_each = var.alert_on_errors ? toset(["lambda-${var.name}-errors"]) : toset([])

  alarm_name          = each.value
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"

  dimensions = {
    FunctionName = var.name
  }

  alarm_description = "This metric monitors lambda errors for function: ${var.name}"
  alarm_actions     = [data.aws_sns_topic.alarm_topic.arn]
}
