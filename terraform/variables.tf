variable "AWS_REGION" {
  default = "us-east-1"
}

# variable "PRIV_KEY_PATH" {
#   default = "vprofilekey"
# }

data "aws_ssm_parameter" "vprofilekey"  {
  name = "vprofilekey"
  with_decryption = false
}

variable "PUB_KEY_PATH" {
  default = "vprofilekey.pub"
}

variable "USERNAME" {
  default = "ubuntu"
}

variable "MYIP" {
  default = "183.83.39.2/32"
}

variable "rmquser" {
  default = "rabbit" # Make it a secret!
}

variable "rmqpass" {
  default = "Gr33n@pple123456" # Make it a secret!
}

variable "dbuser" {
  default = "admin" # Make it a secret!
}

variable "dbpass" {
  default = "admin123" # Make it a secret!
}

variable "dbname" {
  default = "accounts"
}

variable "instance_count" {
  default = "1"
}

variable "VPC_NAME" {
  default = "vprofile-VPC"
}

variable "Zone1" {
  default = "us-east-1a"
}

variable "Zone2" {
  default = "us-east-1b"
}

variable "Zone3" {
  default = "us-east-1c"
}

variable "VpcCIDR" {
  default = "172.21.0.0/16"
}


variable "PubSub1CIDR" {
  default = "172.21.1.0/24"
}

variable "PubSub2CIDR" {
  default = "172.21.2.0/24"
}

variable "PubSub3CIDR" {
  default = "172.21.3.0/24"
}

variable "PrivSub1CIDR" {
  default = "172.21.4.0/24"
}

variable "PrivSub2CIDR" {
  default = "172.21.5.0/24"
}

variable "PrivSub3CIDR" {
  default = "172.21.6.0/24"
}

variable "PROJECT" {
  default = "vprofile"
}
