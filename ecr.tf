#### Create ECR repos for storing Docker images.check "name" {

resource "aws_ecr_repository" "actapp" {
  name                 = "actapp"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    # May update it to true when checking for security vulnerabilities.
    scan_on_push = false
  }

}