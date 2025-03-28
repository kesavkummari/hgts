# Versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.89.0"
    }
  }
}

# Providers 
provider "aws" {
  # Configuration options
  profile = "hgts"
  region  = "ap-south-2"
}

# Stat File
terraform {
  backend "s3" {
    bucket  = "hgts-tf-statefiles"
    key     = "k8s-infra-terraform.tfstate"
    region  = "ap-south-2"
    profile = "hgts"
  }
}


# # Create S3 Bucket in ap-south-2 region
# resource "aws_s3_bucket" "hgts_k8s_statefile" {
#   bucket = "hgts-tf-statefiles"

# }

# resource "aws_s3_bucket_versioning" "hgts_version" {
#   bucket = aws_s3_bucket.hgts_k8s_statefile.id

#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_public_access_block" "hgts_public_access" {
#   bucket = aws_s3_bucket.hgts_k8s_statefile.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true

# }

# output "bucket_name" {
#   value = aws_s3_bucket.hgts_k8s_statefile.id
# }

# Create a VPC in AWS part of region i.e. NV 
resource "aws_vpc" "hgts_k8s_vpc" {
  cidr_block           = var.cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name       = "hgts_k8s"
    Created_By = "Terraform"
  }
}

output "vpc_id" {
  value = aws_vpc.hgts_k8s_vpc.id
}


# Create a Public-Subnet1 part of hgts_k8s_vpc 
resource "aws_subnet" "hgts_k8s_public_subnet_1" {
  vpc_id                  = aws_vpc.hgts_k8s_vpc.id
  cidr_block              = "10.0.1.0/28"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-2a"

  tags = {
    Name       = "hgts_k8s_public_subnet-1"
    created_by = "Terraform"
  }
}

output "public_subnet_1" {
  value = aws_subnet.hgts_k8s_public_subnet_1.id
}

resource "aws_subnet" "hgts_k8s_public_subnet_2" {
  vpc_id                  = aws_vpc.hgts_k8s_vpc.id
  cidr_block              = "10.0.2.0/28"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-2b"

  tags = {
    Name       = "hgts_k8s_public_subnet-2"
    created_by = "Terraform"
  }
}

output "public_subnet_2" {
  value = aws_subnet.hgts_k8s_public_subnet_2.id
}

resource "aws_subnet" "hgts_k8s_private_subnet_1" {
  vpc_id            = aws_vpc.hgts_k8s_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-south-2a"

  tags = {
    Name       = "hgts_k8s_private_subnet-1"
    created_by = "Terraform"
  }
}

output "private_subnet_1" {
  value = aws_subnet.hgts_k8s_private_subnet_1.id
}

resource "aws_subnet" "hgts_k8s_private_subnet_2" {
  vpc_id            = aws_vpc.hgts_k8s_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-south-2b"

  tags = {
    Name       = "hgts_k8s_private_subnet-2"
    created_by = "Terraform"
  }
}

output "private_subnet_2" {
  value = aws_subnet.hgts_k8s_private_subnet_2.id
}


resource "aws_subnet" "hgts_k8s_data_subnet_1" {
  vpc_id            = aws_vpc.hgts_k8s_vpc.id
  cidr_block        = "10.0.5.0/28"
  availability_zone = "ap-south-2a"

  tags = {
    Name       = "hgts_k8s_data_subnet-1"
    created_by = "Terraform"
  }
}

output "data_subnet_1" {
  value = aws_subnet.hgts_k8s_data_subnet_1.id
}

resource "aws_subnet" "hgts_k8s_data_subnet_2" {
  vpc_id            = aws_vpc.hgts_k8s_vpc.id
  cidr_block        = "10.0.6.0/28"
  availability_zone = "ap-south-2b"

  tags = {
    Name       = "hgts_k8s_data_subnet-2"
    created_by = "Terraform"
  }
}

output "data_subnet_2" {
  value = aws_subnet.hgts_k8s_data_subnet_2.id
}

# IGW
resource "aws_internet_gateway" "hgts_k8s_igw" {
  vpc_id = aws_vpc.hgts_k8s_vpc.id

  tags = {
    Name       = "hgts_k8s_igw"
    Created_By = "Terraform"
  }
}

output "internet_gw" {
  value = aws_internet_gateway.hgts_k8s_igw.id
}

# RTB
resource "aws_route_table" "hgts_k8s_rtb_public" {
  vpc_id = aws_vpc.hgts_k8s_vpc.id

  tags = {
    Name       = "hgts_k8s_rtb_public"
    Created_By = "Teerraform"
  }
}
resource "aws_route_table" "hgts_k8s_rtb_private" {
  vpc_id = aws_vpc.hgts_k8s_vpc.id

  tags = {
    Name       = "hgts_k8s_rtb_private"
    Created_By = "Teerraform"
  }
}

# Create the internet Access 
resource "aws_route" "hgts_k8s_rtb_igw" {
  route_table_id         = aws_route_table.hgts_k8s_rtb_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.hgts_k8s_igw.id

}

#Elastic Ipaddress for NAT Gateway
resource "aws_eip" "hgts_k8s_eip" {
  domain = "vpc"
}

# Create Nat Gateway 
resource "aws_nat_gateway" "hgts_k8s_gw" {
  allocation_id = aws_eip.hgts_k8s_eip.id
  subnet_id     = aws_subnet.hgts_k8s_public_subnet_1.id

  tags = {
    Name      = "Nat Gateway"
    Createdby = "Terraform"
  }
}

output "nat_igw" {
  value = aws_nat_gateway.hgts_k8s_gw.id
}

resource "aws_route_table_association" "hgts_k8s_subnet_association1" {
  subnet_id      = aws_subnet.hgts_k8s_public_subnet_1.id
  route_table_id = aws_route_table.hgts_k8s_rtb_public.id
}
resource "aws_route_table_association" "hgts_k8s_subnet_association2" {
  subnet_id      = aws_subnet.hgts_k8s_public_subnet_2.id
  route_table_id = aws_route_table.hgts_k8s_rtb_public.id
}
resource "aws_route_table_association" "hgts_k8s_subnet_association3" {
  subnet_id      = aws_subnet.hgts_k8s_private_subnet_1.id
  route_table_id = aws_route_table.hgts_k8s_rtb_private.id
}
resource "aws_route_table_association" "hgts_k8s_subnet_association4" {
  subnet_id      = aws_subnet.hgts_k8s_private_subnet_2.id
  route_table_id = aws_route_table.hgts_k8s_rtb_private.id
}
resource "aws_route_table_association" "hgts_k8s_subnet_association5" {
  subnet_id      = aws_subnet.hgts_k8s_data_subnet_1.id
  route_table_id = aws_route_table.hgts_k8s_rtb_private.id
}
resource "aws_route_table_association" "hgts_k8s_subnet_association6" {
  subnet_id      = aws_subnet.hgts_k8s_data_subnet_2.id
  route_table_id = aws_route_table.hgts_k8s_rtb_private.id
}

# Allow internet access from NAT Gateway to Private Route Table
resource "aws_route" "hgts_k8s_rtb_private_gw" {
  route_table_id         = aws_route_table.hgts_k8s_rtb_private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.hgts_k8s_gw.id
}

# Network Access Control List 
resource "aws_network_acl" "hgts_k8s_nsg" {
  vpc_id = aws_vpc.hgts_k8s_vpc.id
  subnet_ids = [
    "${aws_subnet.hgts_k8s_public_subnet_1.id}",
    "${aws_subnet.hgts_k8s_public_subnet_2.id}",
    "${aws_subnet.hgts_k8s_private_subnet_1.id}",
    "${aws_subnet.hgts_k8s_private_subnet_2.id}",
    "${aws_subnet.hgts_k8s_data_subnet_1.id}",
    "${aws_subnet.hgts_k8s_data_subnet_2.id}"
  ]

  # Allow ingress of ports from 1024 to 65535
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  # Allow egress of ports from 1024 to 65535
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name      = "hgts_k8s_nsg"
    createdby = "Terraform"
  }
}

output "nacl" {
  value = aws_network_acl.hgts_k8s_nsg.id
}

# EC2 instance Security group
resource "aws_security_group" "hgts_k8s_linux_sg" {
  vpc_id      = aws_vpc.hgts_k8s_vpc.id
  name        = "hgts_k8s_linux_sg"
  description = "To Allow SSH From IPV4 Devices"

  # Allow Ingress / inbound Of port 22 
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  # Allow egress / outbound of all ports 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "hgts_k8s_sg_linux"
    Description = "hgts_k8s allow SSH"
    createdby   = "terraform"
  }

}

output "linux_sg" {
  value = aws_security_group.hgts_k8s_linux_sg.id
}


# EC2 instance Security group
resource "aws_security_group" "hgts_k8s_windows_sg" {
  vpc_id      = aws_vpc.hgts_k8s_vpc.id
  name        = "hgts_k8s_windows_sg"
  description = "To Allow RDP From IPV4 Devices"

  # Allow Ingress / inbound Of port 3389
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
  }
  # Allow egress / outbound of all ports 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sg_hgts_k8s_windows"
    Description = "hgts_k8s allow RDP"
    createdby   = "terraform"
  }

}

output "windows_sg" {
  value = aws_security_group.hgts_k8s_windows_sg.id
}

# EC2 instance Security group
resource "aws_security_group" "hgts_k8s_web_sg" {
  vpc_id      = aws_vpc.hgts_k8s_vpc.id
  name        = "hgts_k8s_web_sg"
  description = "To Allow SSH From IPV4 Devices"

  # Allow Ingress / inbound Of port 22 
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  # Allow Ingress / inbound Of port 80 
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  # Allow Ingress / inbound Of port 8080 
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
  }
  # Allow egress / outbound of all ports 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "hgts_k8s_sg"
    Description = "hgts_k8s allow SSH - RDP - HTTP and Jenkins"
    createdby   = "terraform"
  }

}

output "web_sg" {
  value = aws_security_group.hgts_k8s_web_sg.id
}

# Generate SSH Key Pair Locally
resource "tls_private_key" "hgts_k8s_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save Private Key Locally
resource "local_file" "private_key" {
  filename        = "${path.module}/hgts-shared-k8s.pem"
  content         = tls_private_key.hgts_k8s_key.private_key_pem
  file_permission = "0400"
}

# Create AWS Key Pair using the Generated Public Key
resource "aws_key_pair" "hgts_k8s_keypair" {
  key_name   = "hgts-shared-k8s"
  public_key = tls_private_key.hgts_k8s_key.public_key_openssh
}

output "private_key_path" {
  value = local_file.private_key.filename
}

output "public_key" {
  value = tls_private_key.hgts_k8s_key.public_key_openssh
}

output "keypair" {
  value = aws_key_pair.hgts_k8s_keypair.key_name
}

# resource "aws_acm_certificate" "hgts_fqdn" {
#   domain_name       = "www.hayagreevatechsolutions.in"
#   validation_method = "DNS"

#   subject_alternative_names = [
#     "www.hayagreevatechsolutions.in"
#   ]

#   tags = {
#     Name       = "MyACMCertificate"
#     Created_By = "IaC - Terraform"
#   }
# }

# resource "aws_acm_certificate" "hgts_alias" {
#   domain_name       = "hayagreevatechsolutions.in"
#   validation_method = "DNS"

#   subject_alternative_names = [
#     "hayagreevatechsolutions.in"
#   ]

#   tags = {
#     Name       = "MyACMCertificate"
#     Created_By = "IaC - Terraform"
#   }
# }

# Hosted Zone for the Domain (Ensure the domain is registered in AWS Route 53)
# resource "aws_route53_zone" "main_zone" {
#   name = var.domain_name
# }

# Route 53 Record for ACM Validation
# resource "aws_route53_record" "cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.hgts_fqdn.domain_validation_options : dvo.domain_name => {
#       name  = dvo.resource_record_name
#       type  = dvo.resource_record_type
#       value = dvo.resource_record_value
#     }
#   }

#   zone_id = aws_route53_zone.main_zone.zone_id
#   name    = each.value.name
#   type    = each.value.type
#   records = [each.value.value]
#   ttl     = 60
# }


# output "route53_zone_id" {
#   value = aws_route53_zone.main_zone.zone_id
# }

# output "certificate_fqdn" {
#   value = aws_acm_certificate.hgts_fqdn.arn
# }

# output "certificate_alias" {
#   value = aws_acm_certificate.hgts_alias.arn
# }

# 1. Create IAM Role
resource "aws_iam_role" "hgts_k8s_role" {
  name = "hgts-k8s-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# 2. Attach AmazonEC2RoleforSSM Policy (Example)
resource "aws_iam_role_policy_attachment" "hgts_k8s_role_attachment" {
  role       = aws_iam_role.hgts_k8s_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

# 3. Create IAM Instance Profile
resource "aws_iam_instance_profile" "hgts_k8s_profile" {
  name = "hgts-k8s-profile"
  role = aws_iam_role.hgts_k8s_role.name
}

# resource "aws_instance" "k8s_master" {
#   ami                         = "ami-0995f69ccfab3ef18" # Ubuntu AMI (Mumbai region example)
#   instance_type               = "t3.medium"
#   key_name                    = aws_key_pair.hgts_k8s_keypair.key_name
#   subnet_id                   = aws_subnet.hgts_k8s_public_subnet_1.id
#   associate_public_ip_address = true
#   iam_instance_profile        = aws_iam_instance_profile.hgts_k8s_profile.name

#   user_data = <<-EOF
#               #!/bin/bash
#               hostnamectl set-hostname "k8s-cp.cloudbinary.io"
#               echo "`hostname -I | awk '{ print $1}'` `hostname`" >> /etc/hosts 
#               sudo apt-get update 
#               sudo apt-get install git curl unzip tree wget -y 
#               sudo swapoff -a
#               sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
#               sudo tee /etc/modules-load.d/containerd.conf <<EOF
#               overlay
#               br_netfilter
#               EOF

#               sudo modprobe overlay
#               sudo modprobe br_netfilter

#               sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
#               net.bridge.bridge-nf-call-ip6tables = 1
#               net.bridge.bridge-nf-call-iptables = 1
#               net.ipv4.ip_forward = 1
#               EOF
#               sudo sysctl --system
#               sudo apt-get install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
#               sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
#               sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
#               sudo apt-get update
#               sudo apt-get install -y containerd.io
#               containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
#               sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
#               sudo systemctl restart containerd
#               sudo systemctl enable containerd
#               sudo apt-get update
#               sudo apt-get install -y apt-transport-https ca-certificates curl gpg
#               curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
#               echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
#               sudo apt-get update
#               sudo apt-get install -y kubelet kubeadm kubectl
#               sudo apt-mark hold kubelet kubeadm kubectl
#               sudo systemctl enable --now kubelet
#               export KUBECONFIG=/etc/kubernetes/admin.conf
#               su - ubuntu
#               id
#               pwd
#               cd
#               sudo kubeadm init --control-plane-endpoint=k8s-cp.cloudbinary.in >> /home/ubuntu/k8s-cluster.output
#               mkdir -p $HOME/.kube
#               sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#               sudo chown $(id -u):$(id -g) $HOME/.kube/config
#               kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
#               kubectl cluster-info

#               EOF

#   tags = {
#     Name      = "K8s-Master"
#     CreatedBy = "Terraform"
#   }
# }

resource "aws_instance" "k8s_master" {
  ami                         = "ami-0995f69ccfab3ef18" # Ubuntu AMI (Mumbai region example)
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.hgts_k8s_keypair.key_name
  subnet_id                   = aws_subnet.hgts_k8s_public_subnet_1.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.hgts_k8s_profile.name

  user_data = <<-EOF
              #!/bin/bash
              set -eux  # Enables debugging and stops on errors
              
              # Set Hostname
              hostnamectl set-hostname "k8s-cp.cloudbinary.io"
              echo "$(hostname -I | awk '{print $1}') $(hostname)" >> /etc/hosts 

              # Install necessary utilities
              apt-get update 
              apt-get install -y git curl unzip tree wget 

              # Disable Swap
              swapoff -a
              sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

              # Enable required kernel modules
              cat <<EOF1 | tee /etc/modules-load.d/containerd.conf
              overlay
              br_netfilter
              EOF1

              modprobe overlay
              modprobe br_netfilter

              # Apply sysctl settings for Kubernetes
              cat <<EOF2 | tee /etc/sysctl.d/kubernetes.conf
              net.bridge.bridge-nf-call-ip6tables = 1
              net.bridge.bridge-nf-call-iptables = 1
              net.ipv4.ip_forward = 1
              EOF2
              sysctl --system

              # Install containerd
              apt-get install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
              add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              apt-get update
              apt-get install -y containerd.io

              mkdir -p /etc/containerd
              containerd config default | tee /etc/containerd/config.toml >/dev/null
              sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
              systemctl restart containerd
              systemctl enable containerd

              # Install Kubernetes tools
              apt-get install -y apt-transport-https ca-certificates curl gpg
              curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
              echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
              apt-get update
              apt-get install -y kubelet kubeadm kubectl
              apt-mark hold kubelet kubeadm kubectl
              systemctl enable --now kubelet

              # Initialize Kubernetes Control Plane
              kubeadm init --control-plane-endpoint="k8s-cp.cloudbinary.io" | tee /home/ubuntu/k8s-cluster.output

              # Configure kubectl for ubuntu user
              sudo -u ubuntu mkdir -p /home/ubuntu/.kube
              sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
              sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config

              # Install Calico network plugin
              sudo -u ubuntu kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

              # Verify cluster status
              sudo -u ubuntu kubectl cluster-info
              EOF

  tags = {
    Name      = "K8s-Master"
    CreatedBy = "Terraform"
  }
}




resource "aws_instance" "k8s_worker_node1" {
  ami                         = "ami-0995f69ccfab3ef18" # Ubuntu AMI (Hyderabad region example)
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.hgts_k8s_keypair.key_name
  subnet_id                   = aws_subnet.hgts_k8s_public_subnet_1.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.hgts_k8s_profile.name

  user_data = <<-EOF
              #!/bin/bash
              set -eux  # Enables debugging and stops on errors
              
              # Set Hostname
              hostnamectl set-hostname "k8s-node1.cloudbinary.io"
              echo "$(hostname -I | awk '{print $1}') $(hostname)" >> /etc/hosts 

              # Install necessary utilities
              apt-get update 
              apt-get install -y git curl unzip tree wget 

              # Disable Swap
              swapoff -a
              sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

              # Enable required kernel modules
              cat <<EOF1 | tee /etc/modules-load.d/containerd.conf
              overlay
              br_netfilter
              EOF1

              modprobe overlay
              modprobe br_netfilter

              # Apply sysctl settings for Kubernetes
              cat <<EOF2 | tee /etc/sysctl.d/kubernetes.conf
              net.bridge.bridge-nf-call-ip6tables = 1
              net.bridge.bridge-nf-call-iptables = 1
              net.ipv4.ip_forward = 1
              EOF2
              sysctl --system

              # Install containerd
              apt-get install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
              add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              apt-get update
              apt-get install -y containerd.io

              mkdir -p /etc/containerd
              containerd config default | tee /etc/containerd/config.toml >/dev/null
              sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
              systemctl restart containerd
              systemctl enable containerd

              # Install Kubernetes tools
              apt-get install -y apt-transport-https ca-certificates curl gpg
              curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
              echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
              apt-get update
              apt-get install -y kubelet kubeadm kubectl
              apt-mark hold kubelet kubeadm kubectl
              systemctl enable --now kubelet
              EOF

  tags = {
    Name      = "K8s-WorkerNode-1"
    CreatedBy = "Terraform"
  }
}

