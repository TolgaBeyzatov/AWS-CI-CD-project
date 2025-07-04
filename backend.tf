terraform {
  backend "s3" {
    bucket = "terraformstateproject"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}