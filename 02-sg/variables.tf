variable "project_name" {
    default = "expense" 
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        project = "expense" 
        environment = "Dev"
        Terraform = "true" 
    }
}

variable "db_sg_description" {
    default = "SG for DB mysql description"
}

variable "sg_tags" {
    type = map 
    default = {}
}