
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.37"
    }
  }

  
 backend "s3" {
   bucket = "78s-remote-state"
   key = "expense-dev-apps"
   region = "us-east-1"
   use-lockfile = true
   #dynamodb_table = "daws78s-locking"
   
   
 }

  
}
provider "aws" {
  region = "us-east-1"
}