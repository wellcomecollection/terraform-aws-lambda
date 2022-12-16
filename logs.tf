resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_subscription_filter" "kinesis" {
  name            = "lambda-logs-to-kinesis"
  log_group_name  = aws_cloudwatch_log_group.lambda.name
  destination_arn = data.aws_ssm_parameter.log_destination.value
  filter_pattern  = "" // An empty pattern matches all logs
}

data "aws_ssm_parameter" "log_destination" {
  name = "/logging/esf/destination_arn"
}
