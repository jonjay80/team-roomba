resource "aws_apigatewayv2_api" "djroomba" {
  name          = "djroomba_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "djroomba" {
  api_id                 = aws_apigatewayv2_api.djroomba.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  payload_format_version = "2.0"
  integration_uri        = aws_lambda_function.lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "djroomba_GET_ALL" {
  api_id    = aws_apigatewayv2_api.djroomba.id
  route_key = "GET /items"
  target    = "integrations/${aws_apigatewayv2_integration.djroomba.id}"
}

resource "aws_apigatewayv2_route" "djroomba_GET_ONE" {
  depends_on = [aws_apigatewayv2_route.djroomba_GET_ALL]
  api_id     = aws_apigatewayv2_api.djroomba.id
  route_key  = "GET /items/{id}"
  target     = "integrations/${aws_apigatewayv2_integration.djroomba.id}"
}

resource "aws_apigatewayv2_route" "djroomba_PUT" {
  depends_on = [aws_apigatewayv2_route.djroomba_GET_ONE]
  api_id     = aws_apigatewayv2_api.djroomba.id
  route_key  = "PUT /items"
  target     = "integrations/${aws_apigatewayv2_integration.djroomba.id}"
}

resource "aws_apigatewayv2_route" "djroomba_DELETE" {
  depends_on = [aws_apigatewayv2_route.djroomba_PUT]
  api_id     = aws_apigatewayv2_api.djroomba.id
  route_key  = "DELETE /items/{id}"
  target     = "integrations/${aws_apigatewayv2_integration.djroomba.id}"
}


resource "aws_apigatewayv2_stage" "djroomba" {
  api_id      = aws_apigatewayv2_api.djroomba.id
  name        = "djroomba"
  auto_deploy = "true"
}

