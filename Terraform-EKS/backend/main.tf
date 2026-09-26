terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

#configure terraform backend
terraform {
  backend "s3" {
  bucket = "terraform-eks-ultimate-state-s3-bucket"
  key  = "otel/terraform.tfstate"
  region = "us-east-1"
  encrypt = true
  use_lockfile = true
  }
}
  



