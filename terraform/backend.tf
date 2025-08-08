# configures the remote backend to store the state file in an S3 bucket
terraform {
  backend "s3" {
    bucket = "terraformstateproject"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}