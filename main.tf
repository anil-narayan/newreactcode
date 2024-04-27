terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}


#VPC
resource "aws_vpc" "machine1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "machine1"
  }
}


#PUBLIC SUBNET1
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.machine1.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet1"
  }
}
# PUBLIC SUBNET2
resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.machine1.id
  availability_zone       = "us-east-1b"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet2"
  }
}

# PRIVATE SUBNET1
resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.machine1.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet1"
  }
}

# PRIVATE SUBNET2
resource "aws_subnet" "private_subnet2" {
  vpc_id                  = aws_vpc.machine1.id
  availability_zone       = "us-east-1b"
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet2"
  }
}

#INTERNET GATEWAY
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.machine1.id # Replace with your VPC ID

  tags = {
    Name = "my_igw"
  }
}

#PUBLIC ROUTE TABLE1
resource "aws_route_table" "public_rt1" {
  vpc_id = aws_vpc.machine1.id # Assuming you have a VPC resource named "my_vpc"

  route {
    cidr_block = "0.0.0.0/0"                    # Example destination CIDR block
    gateway_id = aws_internet_gateway.my_igw.id # Assuming you have an Internet Gateway resource named "my_igw"
  }
  tags = {
    Name = "public_rt1"
  }
}

#PUBLIC ROUTE TABLE2
resource "aws_route_table" "public_rt2" {
  vpc_id = aws_vpc.machine1.id # Assuming you have a VPC resource named "my_vpc"

  route {
    cidr_block = "0.0.0.0/0"                    # Example destination CIDR block
    gateway_id = aws_internet_gateway.my_igw.id # Assuming you have an Internet Gateway resource named "my_igw"
  }
  tags = {
    Name = "public_rt2"
  }
}



resource "aws_route_table_association" "public_rt1_association" {
  subnet_id = aws_subnet.public_subnet1.id

  route_table_id = aws_route_table.public_rt1.id
}

resource "aws_route_table_association" "public_rt2_association" {
  subnet_id = aws_subnet.public_subnet2.id

  route_table_id = aws_route_table.public_rt2.id

}





# resource "aws_autoscaling_group" "ASG" {
#   name = "ASG"
#   launch_template {
#     id      = aws_launch_template.apprunlt.id
#     version = "$Latest"
#   }

#   min_size                  = 1
#   max_size                  = 3
#   desired_capacity          = 1
#   vpc_zone_identifier       = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
#   target_group_arns         = [aws_lb_target_group.my_target_group.arn]
#   health_check_type         = "ELB"
#   health_check_grace_period = 300
#   termination_policies      = ["Default"]
#   tag {
#     key                 = "React app asg"
#     value               = "auto scaling groups1"
#     propagate_at_launch = true
   
#   }
#    tag {
#     key                 = "first_name"
#     value               = "anilkumar"
#     propagate_at_launch = true
   
#   }

# }


# resource "aws_launch_template" "apprunlt" {
#   name_prefix   = "template"
#   image_id      = "ami-0c7217cdde317cfec"
#   instance_type = "t2.micro"
#   user_data     = filebase64("${path.module}/script.sh")

#   placement {
#     availability_zone = "us-east-1a"
#   }

#   vpc_security_group_ids = [aws_security_group.sg.id]

#   monitoring {
#     enabled = true
#   }
#   key_name = "project1"

#   tag_specifications {
#     resource_type = "instance"

#     tags = {
#       Name = "Machine"
#     }
  # }





  #  network_interfaces {
  #   associate_public_ip_address = true
  # }

# }

# Create Listener for ALB
resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}


resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"

  # Use the correct attribute to reference the VPC ID
  vpc_id = aws_vpc.machine1.id # Assuming "main" is your VPC resource name

  # Use the "targets" attribute to specify multiple targets

}




# Create Application Load Balancer
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets = [
    aws_subnet.public_subnet1.id,
    aws_subnet.public_subnet2.id

  ]

}


# resource "aws_autoscaling_policy" "Removeinstance" {
#   name                   = "Removeinstance"
#   scaling_adjustment     = -1
#   adjustment_type        = "ChangeInCapacity"
#   cooldown               = 300
  
#   autoscaling_group_name = aws_autoscaling_group.ASG.name

# }

# resource "aws_autoscaling_policy" "addinstance" {
#   name                   = "addinstance"
#   scaling_adjustment     = 1
#   adjustment_type        = "ChangeInCapacity"
#   cooldown               = 300
#   autoscaling_group_name = aws_autoscaling_group.ASG.name
# }



# resource "aws_cloudwatch_metric_alarm" "ADD_Instance_alarm" {
#   alarm_name          = "ADD_Instance_alarm"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = 2
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = 300
#   statistic           = "Average"
#   threshold           = 70
#   alarm_description   = "This alarm is triggered when CPU utilization is greater than or equal to 70% for 2 consecutive periods of 5 minutes each."
#   alarm_actions       = [aws_autoscaling_policy.addinstance.arn]
# }

# resource "aws_cloudwatch_metric_alarm" "Remove_Instance_alarm" {
#   alarm_name          = "Remove_Instance_alarm"
#   comparison_operator = "LessThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = 300
#   statistic           = "Average"
#   threshold           = 20
#   alarm_description   = "This alarm is triggered when CPU utilization is less than 20% for 2 consecutive periods of 5 minutes each."
#   alarm_actions       = [aws_autoscaling_policy.Removeinstance.arn]
# }



resource "aws_sns_topic" "SNS" {
  name = "SNS"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.SNS.arn
  protocol  = "email"
  endpoint  = "n.kumaranil11@gmail.com"
}


resource "aws_eip" "elasticip" {

}

resource "aws_nat_gateway" "natgateway" {
  allocation_id = aws_eip.elasticip.id
  subnet_id     = aws_subnet.public_subnet1.id
}



# PRIVATE ROUTE TABLE
resource "aws_route_table" "private_rt2" {
  vpc_id = aws_vpc.machine1.id # Assuming you have a VPC resource named "my_vpc"

  route {
    cidr_block     = "0.0.0.0/0"              # Example destination CIDR block
    nat_gateway_id = aws_nat_gateway.natgateway.id # Assuming you have an Internet Gateway resource named "my_igw"
  }
  tags = {
    Name = "private_rt2"
  }
}
# PRIVATE ROUTE TABLE
resource "aws_route_table" "private_rt1" {
  vpc_id = aws_vpc.machine1.id # Assuming you have a VPC resource named "my_vpc"

  route {
    cidr_block     = "0.0.0.0/0"              # Example destination CIDR block
    nat_gateway_id = aws_nat_gateway.natgateway.id # Assuming you have an Internet Gateway resource named "my_igw"
  }
  tags = {
    Name = "private_rt1"
  }
}


resource "aws_route_table_association" "private_rt1_association" {
  subnet_id = aws_subnet.private_subnet1.id

  route_table_id = aws_route_table.private_rt1.id
}


resource "aws_route_table_association" "private_rt2_association" {
  subnet_id = aws_subnet.private_subnet2.id

  route_table_id = aws_route_table.private_rt2.id
}







#SECURITY GROUP
resource "aws_security_group" "sg" {
  name        = "sg"
  description = "My security group for EC2 instances"
  vpc_id      = aws_vpc.machine1.id # Replace with your VPC ID

  // Ingress rule allowing inbound SSH traffic from a specific IP range
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your specific IP range
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // Egress rule allowing all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Additional rules can be added as needed
}
















# Bastion public

resource "aws_instance" "public" {
  ami                         = "ami-0c7217cdde317cfec" # Specify the appropriate AMI ID
  instance_type               = "t2.micro"              # Specify the instance type
  subnet_id                   = aws_subnet.public_subnet1.id
  key_name                    = "project1"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]

  

  tags = {
    Name = "bastion"
  }
}


#/resource "aws_instance" "public1" {
  #/ami                         = "ami-0c7217cdde317cfec" # Specify the appropriate AMI ID
  #/instance_type               = "t2.micro"              # Specify the instance type
  #/subnet_id                   = aws_subnet.public_subnet2.id
  #/key_name                    = "key"
  #/associate_public_ip_address = true
  #/vpc_security_group_ids      = [aws_security_group.sg.id]

  

  #/tags = {
    #/Name = "bastion"
  #}
#}








terraform {
  backend "s3" {
    bucket = "practicing-terraform-react-app"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
