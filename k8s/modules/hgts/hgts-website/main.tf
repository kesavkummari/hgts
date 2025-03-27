data "aws_vpc" "selected_vpc" {
  id = "${var.hgts_web_vpc_id}"
}

# data "aws_subnet" "selected_public_subnets" {
#   id    = "${element(var.hgts_web_public_subnets,count.index)}"
#   count = 3
# }

# data "aws_subnet" "selected_private_subnets" {
#   id    = "${element(var.hgts_web_private_subnets,count.index)}"
#   count = 3
# }

data "aws_subnet" "selected_public_subnet" {
  id = var.hgts_web_public_subnets
}

data "aws_subnet" "selected_private_subnet" {
  id = var.hgts_web_private_subnets
}
data "aws_subnet" "selected_data_subnet" {
  id = var.hgts_web_data_subnets
}

resource "aws_iam_instance_profile" "hgts_web_profile" {
  name = "${var.hgts_web_resource_name_prepend}-${var.hgts_web_environment}"
  role = "${aws_iam_role.hgts_web_role.name}"
}

resource "aws_iam_role" "hgts_web_role" {
  name = "${var.hgts_web_resource_name_prepend}-${var.hgts_web_environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

//INSTANCES

//HGTS K8s - CP

resource "aws_instance" "hgts_k8s_cp" {
  lifecycle {
    ignore_changes = ["ami", "ebs_block_device", "tags", "vpc_security_group_ids"]
  }

  ami           = "${var.hgts_web_ami}"
  instance_type = "${var.hgts_web_instance_size}"
  key_name      = "${var.hgts_web_key_name}"
  subnet_id     = "${data.aws_subnet.selected_private_subnet.id}"

  vpc_security_group_ids = [
    "${aws_security_group.hgts_web_sg.id}",
    "${var.hgts_web_admin_web_sg_id}",
  ]

  iam_instance_profile        = "${aws_iam_instance_profile.hgts_web_profile.name}"
  associate_public_ip_address = false

  root_block_device {
    volume_size           = "${var.hgts_web_root_volume_size}"
    volume_type           = "gp3"
    delete_on_termination = true
  }

tags = merge(
  var.hgts_web_additional_tags,
  var.hgts_web_module_tags,
  {
    Name        = "${var.hgts_web_resource_name_prepend}-${var.hgts_web_environment}${var.rds_instance_identifier}"
    Environment = var.hgts_web_environment
  }
)
}


//HGTS K8s - CP

resource "aws_instance" "hgts_k8s_node1" {
  lifecycle {
    ignore_changes = ["ami", "ebs_block_device", "tags", "vpc_security_group_ids"]
  }

  ami           = "${var.hgts_web_ami}"
  instance_type = "${var.hgts_web_instance_size}"
  key_name      = "${var.hgts_web_key_name}"
  subnet_id     = "${data.aws_subnet.selected_private_subnet.id}"

  vpc_security_group_ids = [
    "${aws_security_group.hgts_web_sg.id}",
    "${var.hgts_web_admin_web_sg_id}",
  ]

  iam_instance_profile        = "${aws_iam_instance_profile.hgts_web_profile.name}"
  associate_public_ip_address = false

  root_block_device {
    volume_size           = "${var.hgts_web_root_volume_size}"
    volume_type           = "gp3"
    delete_on_termination = true
  }

tags = merge(
  var.hgts_web_additional_tags,
  var.hgts_web_module_tags,
  {
    Name        = "${var.hgts_web_resource_name_prepend}-${var.hgts_web_environment}${var.rds_instance_identifier}"
    Environment = var.hgts_web_environment
  }
)
}


//Cloudwatch

resource "aws_cloudwatch_metric_alarm" "hgts_web_cloudwatch_recovery" {
  alarm_name                = "${var.hgts_web_environment}-status-check-failed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "StatusCheckFailed_System"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Maximum"
  threshold                 = "1"
  alarm_description         = "This metric monitors ec2 status check"
  insufficient_data_actions = []

  alarm_actions = [
    "arn:aws:automate:ap-south-2:ec2:recover",
  ]

  dimensions = {
    InstanceId = "${aws_instance.hgts_k8s_node1.id}"
  }
}

//Security Groups

//Instance Security Group

//App Instance SG

resource "aws_security_group" "hgts_web_sg" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix = "${var.hgts_web_resource_name_prepend}-${var.hgts_web_environment}"
  description = "${var.hgts_web_resource_name_prepend} Security Group."
  vpc_id      = "${data.aws_vpc.selected_vpc.id}"

tags = merge(
  var.hgts_web_additional_tags,
  var.hgts_web_module_tags,
  {
    "Name"        = "${var.hgts_web_resource_name_prepend}-${var.hgts_web_environment}"
    "Environment" = var.hgts_web_environment
  }
)
}


resource "aws_security_group_rule" "hgts_web_sg_http_rule" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.hgts_web_sg.id}"
  source_security_group_id = "${aws_security_group.hgts_web_sg.id}"
}

resource "aws_security_group_rule" "hgts_web_sg_https_rule" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.hgts_web_sg.id}"
  source_security_group_id = "${aws_security_group.hgts_web_sg.id}"
}

resource "aws_security_group_rule" "hgts_web_sg_app_ssh_rule" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.hgts_web_app_sg.id}"
  source_security_group_id = "${var.hgts_web_admin_windows_sg_id}"
}

resource "aws_security_group_rule" "hgts_web_sg_rule_outgoing" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.hgts_web_sg.id}"

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}


//Cloudwatch

resource "aws_cloudwatch_metric_alarm" "hgts_web_cloudwatch_recovery" {
  alarm_name                = "${var.hgts_web_environment}-status-check-failed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "StatusCheckFailed_System"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Maximum"
  threshold                 = "1"
  alarm_description         = "This metric monitors ec2 status check"
  insufficient_data_actions = []

  alarm_actions = [
    "arn:aws:automate:ap-south-2:ec2:recover",
  ]

  dimensions = {
    InstanceId = "${aws_instance.hgts_k8s_cp.id}"
  }
}


output "app_ami" {
  value = "${var.hgts_web_ami}"
}

output "app_instance_id" {
  value = "${aws_instance.hgts_k8s_cp.id}"
}

output "web_sg_id" {
  value = "${aws_security_group.hgts_web_sg.id}"
}