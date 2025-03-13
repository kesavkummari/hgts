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
    key     = "terraform.tfstate"
    region  = "ap-south-2"
    profile = "hgts"
  }
}


# Create S3 Bucket in ap-south-2 region
resource "aws_s3_bucket" "hgts_shared_statefile" {
  bucket = "hgts-tf-statefiles"

}

resource "aws_s3_bucket_versioning" "hgts_version" {
  bucket = aws_s3_bucket.hgts_shared_statefile.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "hgts_public_access" {
  bucket = aws_s3_bucket.hgts_shared_statefile.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

output "bucket_name" {
  value = aws_s3_bucket.hgts_shared_statefile.id
}

# Create a VPC in AWS part of region i.e. NV 
resource "aws_vpc" "hgts_shared_vpc" {
  cidr_block           = var.cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name       = "hgts_preprod"
    Created_By = "Terraform"
  }
}

output "vpc_id" {
  value = aws_vpc.hgts_shared_vpc.id
}


# Create a Public-Subnet1 part of hgts_shared_vpc 
resource "aws_subnet" "hgts_shared_public_subnet1" {
  vpc_id                  = aws_vpc.hgts_shared_vpc.id
  cidr_block              = "10.0.1.0/28"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-2a"

  tags = {
    Name       = "hgts_shared_public_subnet"
    created_by = "Terraform"
  }
}

output "public_subnet_1" {
  value = aws_subnet.hgts_shared_public_subnet1[*].id
}

resource "aws_subnet" "hgts_shared_public_subnet2" {
  vpc_id                  = aws_vpc.hgts_shared_vpc.id
  cidr_block              = "10.0.2.0/28"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-2b"

  tags = {
    Name       = "hgts_shared_public_subnet"
    created_by = "Terraform"
  }
}

# output "public_subnet_2" {
#   value = aws_subnet.hgts_shared_public_subnet2.id
# }

output "public_subnet_2" {
  value = aws_subnet.hgts_shared_public_subnet2[*].id
}

resource "aws_subnet" "hgts_shared_private_subnet1" {
  vpc_id            = aws_vpc.hgts_shared_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-south-2a"

  tags = {
    Name       = "hgts_shared_private_subnet1"
    created_by = "Terraform"
  }
}
# output "private_subnet_1" {
#   value = aws_subnet.hgts_shared_private_subnet1.id
# }
output "private_subnet_1" {
  value = aws_subnet.hgts_shared_private_subnet1[*].id
}

resource "aws_subnet" "hgts_shared_private_subnet2" {
  vpc_id            = aws_vpc.hgts_shared_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-south-2b"

  tags = {
    Name       = "hgts_shared_private_subnet2"
    created_by = "Terraform"
  }
}
# output "private_subnet_2" {
#   value = aws_subnet.hgts_shared_private_subnet2.id
# }
output "private_subnet_2" {
  value = aws_subnet.hgts_shared_private_subnet2[*].id
}

# IGW
resource "aws_internet_gateway" "hgts_shared_igw" {
  vpc_id = aws_vpc.hgts_shared_vpc.id

  tags = {
    Name       = "hgts_shared_igw"
    Created_By = "Terraform"
  }
}

output "internet_gw" {
  value = aws_internet_gateway.hgts_shared_igw.id
}

# RTB
resource "aws_route_table" "hgts_shared_rtb_public" {
  vpc_id = aws_vpc.hgts_shared_vpc.id

  tags = {
    Name       = "hgts_shared_rtb_public"
    Created_By = "Teerraform"
  }
}
resource "aws_route_table" "hgts_shared_rtb_private" {
  vpc_id = aws_vpc.hgts_shared_vpc.id

  tags = {
    Name       = "hgts_shared_rtb_private"
    Created_By = "Teerraform"
  }
}

# Create the internet Access 
resource "aws_route" "hgts_shared_rtb_igw" {
  route_table_id         = aws_route_table.hgts_shared_rtb_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.hgts_shared_igw.id

}

#Elastic Ipaddress for NAT Gateway
resource "aws_eip" "hgts_shared_eip" {
  domain = "vpc"
}

# Create Nat Gateway 
resource "aws_nat_gateway" "hgts_shared_gw" {
  allocation_id = aws_eip.hgts_shared_eip.id
  subnet_id     = aws_subnet.hgts_shared_public_subnet1.id

  tags = {
    Name      = "Nat Gateway"
    Createdby = "Terraform"
  }
}

output "nat_igw" {
  value = aws_nat_gateway.hgts_shared_gw.id
}

resource "aws_route_table_association" "hgts_shared_subnet_association1" {
  subnet_id      = aws_subnet.hgts_shared_public_subnet1.id
  route_table_id = aws_route_table.hgts_shared_rtb_public.id
}
resource "aws_route_table_association" "hgts_shared_subnet_association2" {
  subnet_id      = aws_subnet.hgts_shared_public_subnet2.id
  route_table_id = aws_route_table.hgts_shared_rtb_public.id
}
resource "aws_route_table_association" "hgts_shared_subnet_association3" {
  subnet_id      = aws_subnet.hgts_shared_private_subnet1.id
  route_table_id = aws_route_table.hgts_shared_rtb_private.id
}
resource "aws_route_table_association" "hgts_shared_subnet_association4" {
  subnet_id      = aws_subnet.hgts_shared_private_subnet2.id
  route_table_id = aws_route_table.hgts_shared_rtb_private.id
}


# Allow internet access from NAT Gateway to Private Route Table
resource "aws_route" "hgts_shared_rtb_private_gw" {
  route_table_id         = aws_route_table.hgts_shared_rtb_private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.hgts_shared_gw.id
}

# Network Access Control List 
resource "aws_network_acl" "hgts_shared_nsg" {
  vpc_id = aws_vpc.hgts_shared_vpc.id
  subnet_ids = [
    "${aws_subnet.hgts_shared_public_subnet1.id}",
    "${aws_subnet.hgts_shared_public_subnet2.id}",
    "${aws_subnet.hgts_shared_private_subnet1.id}",
    "${aws_subnet.hgts_shared_private_subnet2.id}"
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
    Name      = "hgts_shared_nsg"
    createdby = "Terraform"
  }
}

output "nacl" {
  value = aws_network_acl.hgts_shared_nsg.id
}

# EC2 instance Security group
resource "aws_security_group" "hgts_shared_linux_sg" {
  vpc_id      = aws_vpc.hgts_shared_vpc.id
  name        = "hgts_shared_linux_sg"
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
    Name        = "hgts_shared_sg_linux"
    Description = "hgts_shared allow SSH"
    createdby   = "terraform"
  }

}

output "linux_sg" {
  value = aws_security_group.hgts_shared_linux_sg.id
}


# EC2 instance Security group
resource "aws_security_group" "hgts_shared_windows_sg" {
  vpc_id      = aws_vpc.hgts_shared_vpc.id
  name        = "hgts_shared_windows_sg"
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
    Name        = "sg_hgts_shared_windows"
    Description = "hgts_shared allow RDP"
    createdby   = "terraform"
  }

}

output "windows_sg" {
  value = aws_security_group.hgts_shared_windows_sg.id
}

# EC2 instance Security group
resource "aws_security_group" "hgts_shared_web_sg" {
  vpc_id      = aws_vpc.hgts_shared_vpc.id
  name        = "hgts_shared_web_sg"
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
    Name        = "hgts_shared_sg"
    Description = "hgts_shared allow SSH - RDP - HTTP and Jenkins"
    createdby   = "terraform"
  }

}

output "web_sg" {
  value = aws_security_group.hgts_shared_web_sg.id
}

# Generate SSH Key Pair Locally
resource "tls_private_key" "hgts_shared_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save Private Key Locally
resource "local_file" "private_key" {
  filename        = "${path.module}/hgts-shared-preprod.pem"
  content         = tls_private_key.hgts_shared_key.private_key_pem
  file_permission = "0400"
}

# Create AWS Key Pair using the Generated Public Key
resource "aws_key_pair" "hgts_shared_keypair" {
  key_name   = "hgts-shared-preprod"
  public_key = tls_private_key.hgts_shared_key.public_key_openssh
}

output "private_key_path" {
  value = local_file.private_key.filename
}

output "public_key" {
  value = tls_private_key.hgts_shared_key.public_key_openssh
}

output "keypair" {
  value = aws_key_pair.hgts_shared_keypair.key_name
}


resource "aws_codebuild_project" "codebuild" {
  name         = "hgts-src"
  service_role = aws_iam_role.codebuild_role.arn
  source {
    type     = "GITHUB"
    location = var.github_repo_url
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:5.0"
    type         = "LINUX_CONTAINER"
  }
  artifacts {
    type = "NO_ARTIFACTS"
  }
}

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_codepipeline" "pipeline" {
  name     = "hgts-pipeline"
  role_arn = aws_iam_role.pipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.artifact_bucket.id
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        Owner      = "kesavkummari"
        Repo       = var.github_repo_url
        Branch     = "main"
        OAuthToken = "your-github-token"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "BuildAction"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.codebuild.name
      }
    }
  }
}

resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "hgts-codepipeline-artifacts"
}

resource "aws_iam_role" "pipeline_role" {
  name = "codepipeline-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "pipeline_policy" {
  name       = "codepipeline-policy-attach"
  roles      = [aws_iam_role.pipeline_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
            
}
