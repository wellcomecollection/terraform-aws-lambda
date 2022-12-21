module "example_lambda" {
  source = "../"

  name     = "example-lambda"
  runtime  = "nodejs16.x"
  handler  = "index.handler"
  filename = data.archive_file.lambda_zip.output_path
}

data "archive_file" "lambda_zip" {
  type             = "zip"
  source_file      = "${path.module}/index.js"
  output_file_mode = "0666"
  output_path      = "${path.module}/lambda.zip"
}
