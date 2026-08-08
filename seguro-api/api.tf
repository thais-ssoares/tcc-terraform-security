resource "aws_api_gateway_rest_api" "api" {
  name = "secure-api"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "test"
}

# -------------------------
# MÉTODO COM API KEY
# -------------------------

resource "aws_api_gateway_method" "method" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = "GET"

  authorization = "NONE"

  api_key_required = true
}

# -------------------------
# API KEY
# -------------------------

resource "aws_api_gateway_api_key" "api_key" {
  name = "secure-api-key"
}

resource "aws_api_gateway_usage_plan" "usage_plan" {

  depends_on = [
    aws_api_gateway_stage.prod
  ]

  name = "secure-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.prod.stage_name
  }
}

# -------------------------
# INTEGRAÇÃO API -> LAMBDA
# -------------------------

resource "aws_api_gateway_integration" "integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"

  uri = aws_lambda_function.lambda.invoke_arn
}

# -------------------------
# PERMISSÃO PARA API GATEWAY
# INVOCAR A LAMBDA
# -------------------------

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name

  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# -------------------------
# DEPLOY
# -------------------------

resource "aws_api_gateway_deployment" "deployment" {

  depends_on = [
    aws_api_gateway_method.method,
    aws_api_gateway_integration.integration
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"

}

