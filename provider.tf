terraform {
  required_version = ">= 0.14.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.72.0"
    }
    random = "~> 2.3.0"
    kubernetes = {
       source  = "hashicorp/kubernetes"
       version = ">=2.10"
     }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0"
    }
  }
   backend "s3" {
     bucket = "k8s-lihi"
     key    = "k8s-lihi-bucket/k8s_lihi_bucket.tfstate"
     region = "us-east-1"
   }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "k8s-lihi"
}

resource "aws_s3_bucket" "loggingb" {
  bucket = "loggingb"
}
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "dynmodb"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      owner   = "lihi reisman"
      purpose = "k8s"
      context = "test"
    }
  }
}