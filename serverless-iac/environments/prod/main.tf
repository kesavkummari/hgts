# Application Load Balancer (ALB)
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets           = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "ApplicationLoadBalancer"
  }
}

# Target Group for HTTP (Port 80)
resource "aws_lb_target_group" "tg_http" {
  name     = "tg-http"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
}

# Target Group for HTTPS (Port 443)
resource "aws_lb_target_group" "tg_https" {
  name     = "tg-https"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.main_vpc.id
}

# Load Balancer Listener for HTTP
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_http.arn
  }
}

# Load Balancer Listener for HTTPS
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_https.arn
  }
}

# Auto Scaling Group (ASG)
resource "aws_launch_template" "asg_lt" {
  name          = "asg-launch-template"
  image_id      = "ami-12345678" # Replace with actual AMI ID
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.asg_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ASGInstance"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  desired_capacity    = 2
  max_size           = 3
  min_size           = 1

  launch_template {
    id      = aws_launch_template.asg_lt.id
    version = "$Latest"
  }

  target_group_arns = [
    aws_lb_target_group.tg_http.arn,
    aws_lb_target_group.tg_https.arn
  ]

  tag {
    key                 = "Name"
    value               = "ASGInstance"
    propagate_at_launch = true
  }
}

# CloudWatch Alarm for High CPU
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "HighCPUUsage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = 120
  statistic         = "Average"
  threshold         = 80
  alarm_actions     = []
}

# RDS in Private Subnet
resource "aws_db_instance" "rds" {
  identifier            = "mydb"
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_type         = "gp2"
  db_name              = "mydatabase"
  username            = "admin"
  password            = "password123"  # Use AWS Secrets Manager for production
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot  = true
}

# DB Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "RDSSubnetGroup"
  }
}