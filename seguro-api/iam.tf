resource "aws_iam_role" "lambda_role" {
  name = "lambda-role-api-secure"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"

      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# -------------------------
# POLÍTICA RESTRITA
# -------------------------

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda-policy-api-secure"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# -------------------------
# CLOUDWATCH
# -------------------------

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/secure_api_lambda"
  retention_in_days = 7
}
