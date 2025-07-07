output "ecr_repo_app" {
  description = "ECR repository URL for actapp image"
  value       = aws_ecr_repository.actapp.repository_url
}