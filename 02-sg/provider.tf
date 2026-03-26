terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.34.0"
    }
  }

  
 backend "s3" {
   bucket = "78s-remote-state"
   key = "expense-dev-sg"
   region = "us-east-1"
   dynamodb_table = "daws78s-locking"
   
 }

  
}

provider "aws" {
  region = "us-east-1"
}
