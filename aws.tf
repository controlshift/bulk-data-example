provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}
