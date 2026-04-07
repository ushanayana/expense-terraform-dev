variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
  default = {
    Project = "expense"
    Environment = "dev"
    Terraform = "true"
  }
}

variable "zone_name" {
  default = "daws78s.shop"
}

variable "zone_id" {
  default = "Z02504593KYJCKDGD1K54"
}