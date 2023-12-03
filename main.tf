provider "aws" {
  region = "us-east-1"  # Substitua pela sua região desejada
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
  required_version = ">= 1.6.0"


    backend "s3" {
    bucket = "lincolnrpm-bucket"
    key   = "terraform/terraform.tfstate"
    region = "us-east-1"
    encrypt        = true
  }
}



