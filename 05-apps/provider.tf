terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.37" # Terraform AWS provider version
    }
  }

  backend "s3" {
    bucket  = "78s-remote-state" # Replace with your unique bucket name
    key     = "expense-dev-apps"
    region  = "us-east-1"
    encrypt = true
    use_lockfile   = true
  }
}

provider "aws" {
  region = "us-east-1"
}
# terraform {
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#       version = "6.37"
#     }
#   }

  
#  backend "s3" {
#    bucket = "78s-remote-state"
#    key = "expense-dev-apps"
#    region = "us-east-1"
#    dynamodb_table = "daws78s-locking"
   
#  }

  
# }

# provider "aws" {
#   region = "us-east-1"
# }
