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

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each = var.error_alarm_topic_arn != null ? toset([var.error_alarm_topic_arn]) : toset([])

  alarm_name          = "lambda-${var.name}-errors"
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

  alarm_description = "${local.alarm_description_prefix}This metric monitors lambda errors for function: ${var.name}"
  alarm_actions     = [each.value]

  tags = local.alarm_tags
}

locals {
  // Tags and description prefix from the alert routing ADR (wellcomecollection/docs adr/alert_routing.md)
  alarm_tags = merge(
    var.alarm_tags,
    { severity = var.alarm_severity },
    var.alarm_component != null ? { "backplane:component" = var.alarm_component } : {},
    var.alarm_repository != null ? { "github.com/project-slug" = var.alarm_repository } : {},
  )

  alarm_description_prefix = var.alarm_component != null ? "[component=${var.alarm_component} severity=${var.alarm_severity}] " : ""
}
