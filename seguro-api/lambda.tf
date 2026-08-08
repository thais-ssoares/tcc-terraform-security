resource "aws_lambda_function" "lambda" {
  function_name = "secure_api_lambda"

  role    = aws_iam_role.lambda_role.arn
  runtime = "python3.12"
  handler = "index.handler"

  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  timeout = 10

  # senha removida
  environment {
    variables = {
      ENVIRONMENT = "production"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda_logs
  ]
}
