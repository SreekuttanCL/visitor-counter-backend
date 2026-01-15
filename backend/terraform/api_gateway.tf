# API Gateway REST API
resource "aws_api_gateway_rest_api" "visitor_api" {
  name        = "visitor-counter-api"
  description = "API for Visitor Counter Lambda"
}

# Root Resource ID ("/")
data "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  path        = "/"
}

resource "aws_api_gateway_method" "get_visitor" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  resource_id   = data.aws_api_gateway_resource.root.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.visitor_api.id
  resource_id             = data.aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.get_visitor.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.visitor_lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "cors_response" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = data.aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.get_visitor.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "cors_integration" {
  depends_on   = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = data.aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.get_visitor.http_method
  status_code = aws_api_gateway_method_response.cors_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_deployment" "visitor_api_deploy" {
  depends_on = [aws_api_gateway_integration.lambda_integration]

  rest_api_id = aws_api_gateway_rest_api.visitor_api.id

  triggers = {
    redeploy = timestamp()  # <-- forces redeploy every apply
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  deployment_id = aws_api_gateway_deployment.visitor_api_deploy.id

  description = "Production stage for visitor API"
}


resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.visitor_api.execution_arn}/*/*"
}

