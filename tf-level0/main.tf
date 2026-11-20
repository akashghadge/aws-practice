terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "demo" {
  bucket = "akash-tf-level0-demo-12345" # must be globally unique
  tags = {
    Env = "learning"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.demo.bucket
}
