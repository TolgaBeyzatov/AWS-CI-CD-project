# module "ecr" {
#   source = "terraform-aws-modules/ecr/aws"

#   repository_name = "actapp"

#   repository_read_write_access_arns = ["arn:aws:iam::127214174680:role/terraform"]
#   repository_lifecycle_policy = jsonencode({
#     rules = [
#       {
#         rulePriority = 1,
#         description  = "Keep last 30 images",
#         selection = {
#           tagStatus     = "tagged",
#           tagPrefixList = ["v"],
#           countType     = "imageCountMoreThan",
#           countNumber   = 30
#         },
#         action = {
#           type = "expire"
#         }
#       }
#     ]
#   })

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }
# }



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