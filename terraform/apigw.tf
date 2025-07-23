# Creating VPC Link configured with the private subnets.
resource "aws_apigatewayv2_vpc_link" "vpclink_apigw_to_alb" {
  name               = "vpclink_apigw_to_alb"
  security_group_ids = [aws_security_group.allow_access_ecs_service.id]
  subnet_ids         = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
}

# Creating the API Gateway HTTP endpoint
resource "aws_apigatewayv2_api" "apigw_http_endpoint" {
  name          = "vpro-gateway"
  protocol_type = "HTTP"
}

# Creating the API Gateway HTTP_PROXY integration between the created API and the private ALB via the VPC Link. 

resource "aws_apigatewayv2_integration" "apigw_integration" {
  api_id           = aws_apigatewayv2_api.apigw_http_endpoint.id
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_lb_listener.listener.arn

  integration_method     = "ANY"
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.vpclink_apigw_to_alb.id
  payload_format_version = "1.0" # The format of the payload sent to an integration. 1.0 is default. 
  depends_on             = [aws_apigatewayv2_vpc_link.vpclink_apigw_to_alb, aws_apigatewayv2_api.apigw_http_endpoint, aws_lb_listener.listener]
}

# API GW route with ANY method. 
resource "aws_apigatewayv2_route" "apigw_route" {
  api_id     = aws_apigatewayv2_api.apigw_http_endpoint.id
  route_key  = "ANY /{proxy+}"
  target     = "integrations/${aws_apigatewayv2_integration.apigw_integration.id}"
  depends_on = [aws_apigatewayv2_integration.apigw_integration]
}

# Set a default stage aws_apigatewayv2_domain_name
resource "aws_apigatewayv2_stage" "apigw_stage" {
  api_id      = aws_apigatewayv2_api.apigw_http_endpoint.id
  name        = "$default"
  auto_deploy = true
  depends_on  = [aws_apigatewayv2_api.apigw_http_endpoint]
}

resource "aws_apigatewayv2_domain_name" "domain_name" {
  domain_name = "*.tfbbb.xyz"

  domain_name_configuration {
    certificate_arn = data.aws_acm_certificate.issued.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "stage_mapping" {
  api_id      = aws_apigatewayv2_api.apigw_http_endpoint.id
  stage       = aws_apigatewayv2_stage.apigw_stage.id
  domain_name = aws_apigatewayv2_domain_name.domain_name.id # Links the mapping to the aws_api_gateway_domain.  
}