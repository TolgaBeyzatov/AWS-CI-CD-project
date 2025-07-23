output "ecr_repo_app" {
  description = "ECR repository URL for actapp image"
  value       = aws_ecr_repository.actapp.repository_url
}

output "RDSEndpoint" {
  description = "RDS Endpoint"
  value       = aws_db_instance.vprofile-rds.endpoint
}

output "MemcachedEndpoint" {
  description = "Memcached Endpoint"
  value       = aws_elasticache_cluster.vprofile-cache.configuration_endpoint
}

# output "RabbitMQEndpoint" {
#   description = "RabbitMq Endpoint"
#   value       = aws_mq_broker.vprofile-rmq.instances.0.endpoints
# }

# Generated API GW endpoint URL that can be used to access the application running on a private ECS Fargate cluster.
output "apigw_endpoint" {
  value       = aws_apigatewayv2_api.apigw_http_endpoint.api_endpoint
  description = "API Gateway Endpoint"
}