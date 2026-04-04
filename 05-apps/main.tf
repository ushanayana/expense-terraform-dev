resource "aws_instance" "backend" {
  ami           = data.aws_ami.ami_info.id
  instance_type = "t3.micro"
  subnet_id = local.private_subnet_ids
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]

  tags = merge(
    {
        Name = "${var.project_name}-${var.environment}-backend"
    }
  )
}



resource "terraform_data" "backend" {
  triggers_replace = [
    aws_instance.backend.id
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.backend.private_ip
  }

  provisioner "file" {
    source      = "bootstrap.sh" # Local file path
    destination = "/tmp/bootstrap.sh"    # Destination path on the remote machine
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/bootstrap.sh",
        "sudo sh /tmp/bootstrap.sh backend"
    ]
  }
} 

# resource "aws_instance" "frontend" {
#   ami           = data.aws_ami.ami_info.id
#   instance_type = "t3.micro"
#   subnet_id = local.public_subnet_ids
#   vpc_security_group_ids = [data.aws_ssm_parameter.frontend_sg_id.value]

#   tags = merge(
#     {
#         Name = "${var.project_name}-${var.environment}-frontend"
#     }
#   )
# }



# resource "terraform_data" "frontend" {
#   triggers_replace = [
#     aws_instance.frontend.id
#   ]

#   connection {
#     type     = "ssh"
#     user     = "ec2-user"
#     password = "DevOps321"
#     host     = aws_instance.frontend.public_ip
#     timeout = "5m"
#   }

#   provisioner "file" {
#     source      = "bootstrap.sh" # Local file path
#     destination = "/tmp/bootstrap.sh"    # Destination path on the remote machine
#   }

#   provisioner "remote-exec" {
#     inline = [
#         "chmod +x /tmp/bootstrap.sh",
#         "sudo sh /tmp/bootstrap.sh frontend"
#     ]
#   }
  # provisioner "remote-exec" {
  # inline = [
  #   "sudo dnf update -y",
  #   "sudo dnf install -y nginx",
  #   "sudo nginx -t",                 # validate config
  #   "sudo systemctl enable nginx",
  #   "sudo systemctl restart nginx"
  # ]
}


 
  
}

# resource "aws_ec2_instance_state" "catalogue" {
#   instance_id = aws_instance.catalogue.id
#   state       = "stopped"
#   depends_on = [terraform_data.catalogue]
# }

# resource "aws_ami_from_instance" "catalogue" {
#   # roboshop-dev-catalogue-v3-i-h468sghy
#   name               = "${var.project}-${var.environment}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
#   source_instance_id = aws_instance.catalogue.id
#   depends_on = [aws_ec2_instance_state.catalogue]
#   tags = merge(
#     {
#         Name = "${var.project}-${var.environment}-catalogue"
#     },
#     local.common_tags
#   )
# }

# resource "aws_lb_target_group" "catalogue" {
#   name     = "${var.project}-${var.environment}-catalogue"
#   port     = 8080
#   protocol = "HTTP"
#   vpc_id   = local.vpc_id
#   deregistration_delay = 60

#   health_check {
#     healthy_threshold = 2
#     interval = 10
#     matcher = "200-299"
#     path = "/health"
#     port = 8080
#     protocol = "HTTP"
#     timeout = 2
#     unhealthy_threshold = 3
#   }
# }

# resource "aws_launch_template" "catalogue" {
#   name = "${var.project}-${var.environment}-catalogue"
#   image_id = aws_ami_from_instance.catalogue.id

#   # once autoscaling sees less traffic, it will terminate the instance
#   instance_initiated_shutdown_behavior = "terminate"
#   instance_type = "t3.micro"
#   vpc_security_group_ids = [local.catalogue_sg_id]

#   # each time we apply terraform this version will be updated as default
#   update_default_version = true
  
#   # tags for instances created by launch template through autoscaling
#   tag_specifications {
#     resource_type = "instance"

#     tags = merge(
#         {
#             Name = "${var.project}-${var.environment}-catalogue"
#         },
#         local.common_tags
#     )
#   }
#   # tags for volumes created by instances
#   tag_specifications {
#     resource_type = "volume"

#     tags = merge(
#         {
#             Name = "${var.project}-${var.environment}-catalogue"
#         },
#         local.common_tags
#     )
#   }
#   # tags for launch template
#   tags = merge(
#         {
#             Name = "${var.project}-${var.environment}-catalogue"
#         },
#         local.common_tags
#     )
# }

# resource "aws_autoscaling_group" "catalogue" {
#   name                      = "${var.project}-${var.environment}-catalogue"
#   max_size                  = 10
#   min_size                  = 1
#   health_check_grace_period = 120
#   health_check_type         = "ELB"
#   desired_capacity          = 1
#   force_delete              = false

#   launch_template {
#     id      = aws_launch_template.catalogue.id
#     version = "$Latest"
#   }

  
#   vpc_zone_identifier       = [local.private_subnet_id]
#   target_group_arns = [aws_lb_target_group.catalogue.arn]

#   instance_refresh {
#     strategy = "Rolling"
#     preferences {
#       min_healthy_percentage = 50
#     }
#     triggers = ["launch_template"]
#   }

#   dynamic "tag" {
#     for_each = merge(
#         {
#             Name = "${var.project}-${var.environment}-catalogue"
#         },
#         local.common_tags
#     )
#     content {
#       key                 = tag.key
#       value               = tag.value
#       propagate_at_launch = true
#     }
#   }

#   # with in 15min autoscaling should be successful
#   timeouts {
#     delete = "15m"
#   }
# }

# resource "aws_autoscaling_policy" "catalogue" {
#   autoscaling_group_name = aws_autoscaling_group.catalogue.name
#   name                   = "${var.project}-${var.environment}-catalogue"
#   policy_type            = "TargetTrackingScaling"
#   estimated_instance_warmup = 120

#   target_tracking_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ASGAverageCPUUtilization"
#     }

#     target_value = 70.0
#   }
# }

# # This depends on target group
# resource "aws_lb_listener_rule" "catalogue" {
#   listener_arn = local.backend_alb_listener_arn
#   priority     = 10

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.catalogue.arn
#   }

#   condition {
#     host_header {
#       values = ["catalogue.backend-alb-${var.environment}.${var.domain_name}"]
#     }
#   }
# }

# resource "terraform_data" "catalogue_delete" {
#   triggers_replace = [
#     aws_instance.catalogue.id
#   ]
#   depends_on = [aws_autoscaling_policy.catalogue]
  
#   # it executes in bastion
#   provisioner "local-exec" {
#     command = "aws ec2 terminate-instances --instance-ids ${aws_instance.catalogue.id} "
#   }
# }

# # module "backend" {
# #   source  = "terraform-aws-modules/ec2-instance/aws"

# #   name = "${var.project_name}-${var.environment}-backend"

# #   instance_type = "t3.micro"
# #   vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
# #   subnet_id     =   local.private_subnet_ids
# #   ami = data.aws_ami.ami_info.id 

# #   tags = merge(
# #     var.common_tags,
# #     {
# #       Name = "${var.project_name}-${var.environment}-backend"
# #   }
# #   )
# # }

# # module "frontend" {
# #   source  = "terraform-aws-modules/ec2-instance/aws"

# #   name = "${var.project_name}-${var.environment}-frontend"

# #   instance_type = "t3.micro"
# #   vpc_security_group_ids = [data.aws_ssm_parameter.frontend_sg_id.value]
# #   subnet_id     =   local.public_subnet_ids
# #   ami = data.aws_ami.ami_info.id 

# #   tags = merge(
# #     var.common_tags,
# #     {
# #       Name = "${var.project_name}-${var.environment}-frontend"
# #   }
# #   )
# # }

# # module "ansible" {
# #   source  = "terraform-aws-modules/ec2-instance/aws"

# #   name = "${var.project_name}-${var.environment}-ansible"

# #   instance_type          = "t3.micro"
# #   vpc_security_group_ids = [data.aws_ssm_parameter.ansible_sg_id.value]
# #   # convert StringList to list and get first element
# #   subnet_id = local.public_subnet_ids
# #   ami = data.aws_ami.ami_info.id
# #   user_data = file("expense.sh")
# #   tags = merge(
# #     var.common_tags,
# #     {
# #         Name = "${var.project_name}-${var.environment}-ansible"
# #     }
# #   )
# #   depends_on = [ module.backend,module.frontend ]
# # }


# # module "records" {
# #   source  = "terraform-aws-modules/route53/aws//modules/records"
# #   version = "~> 2.0"

# #   zone_name = var.zone_name

# #   records = [
# #     {
# #       name    = "backend"
# #       type    = "A"
# #       ttl     = 1
# #       records = [
# #         module.backend.private_ip
# #       ]
# #     },
# #     {
# #       name    = "frontend"
# #       type    = "A"
# #       ttl     = 1
# #       records = [
# #         module.frontend.private_ip
# #       ]
# #     },
# #     {
# #       name    = "" #daws78s.shop
# #       type    = "A"
# #       ttl     = 1
# #       records = [
# #         module.frontend.public_ip
# #       ]
# #     },
# #   ]

# # }