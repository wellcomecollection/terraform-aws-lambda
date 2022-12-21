output "lambda" {
  value = aws_lambda_function.main
}

output "lambda_role" {
  value = aws_iam_role.lambda
}
