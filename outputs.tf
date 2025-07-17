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