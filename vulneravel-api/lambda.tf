resource "aws_lambda_function" "lambda" {
  function_name = "vulnerable_api_lambda"

  role    = aws_iam_role.lambda_role.arn
  runtime = "python3.9"
  handler = "index.handler"

  filename = "lambda.zip"

  environment {
    variables = {
      DB_PASSWORD = "123456" # ❌ segredo exposto
    }
  }
}

