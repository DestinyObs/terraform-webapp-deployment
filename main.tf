provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# VPC Creation
resource "aws_vpc" "webapp_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "WebApp-VPC"
  }
}

# Subnet Creation
resource "aws_subnet" "webapp_subnet_1" {
  vpc_id            = aws_vpc.webapp_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "WebApp-Subnet-1"
  }
}

resource "aws_subnet" "webapp_subnet_2" {
  vpc_id            = aws_vpc.webapp_vpc.id
  cidr_block        = "10.0.2.0/24"  # Adjusted to avoid conflict
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "WebApp-Subnet-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "webapp_igw" {
  vpc_id = aws_vpc.webapp_vpc.id

  tags = {
    Name = "WebApp-IGW"
  }
}

# Route Table
resource "aws_route_table" "webapp_route_table" {
  vpc_id = aws_vpc.webapp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webapp_igw.id
  }

  tags = {
    Name = "WebApp-Route-Table"
  }
}

# Associate Route Table with Subnets
resource "aws_route_table_association" "webapp_route_assoc_1" {
  subnet_id      = aws_subnet.webapp_subnet_1.id
  route_table_id = aws_route_table.webapp_route_table.id
}

resource "aws_route_table_association" "webapp_route_assoc_2" {
  subnet_id      = aws_subnet.webapp_subnet_2.id
  route_table_id = aws_route_table.webapp_route_table.id
}

# Security Group
resource "aws_security_group" "web_sg" {
  vpc_id      = aws_vpc.webapp_vpc.id
  description = "Allow HTTP and SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebApp-SG"
  }
}

# Key Pair
resource "tls_private_key" "webapp_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "webapp_key" {
  key_name   = "webapp-key"
  public_key = tls_private_key.webapp_key.public_key_openssh
}

output "private_key" {
  value     = tls_private_key.webapp_key.private_key_pem
  sensitive = true
}

resource "aws_instance" "webapp_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.webapp_subnet_1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = aws_key_pair.webapp_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install apache2 -y
              echo "${var.webpage_content}" > /var/www/html/index.html
              systemctl start apache2
              systemctl enable apache2
              EOF

  tags = {
    Name = "WebApp-Instance"
  }
}


# Load Balancer
resource "aws_lb" "webapp_lb" {
  name               = "webapp-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.webapp_subnet_1.id, aws_subnet.webapp_subnet_2.id]

  tags = {
    Name = "WebApp-LB"
  }
}

# Register instance with target group
resource "aws_lb_target_group_attachment" "webapp_tg_attachment" {
  target_group_arn = aws_lb_target_group.webapp_tg.arn
  target_id        = aws_instance.webapp_instance.id
  port             = 80
}

# Target Group
resource "aws_lb_target_group" "webapp_tg" {
  name     = "webapp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.webapp_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener
resource "aws_lb_listener" "webapp_listener" {
  load_balancer_arn = aws_lb.webapp_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_tg.arn
  }
}
