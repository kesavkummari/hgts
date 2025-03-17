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


resource "aws_acm_certificate" "my_cert" {
  domain_name       = "hayagreevatechsolutions.in"
  validation_method = "DNS"

  subject_alternative_names = [
    "www.hayagreevatechsolutions.in"
  ]

  tags = {
    Name       = "MyACMCertificate"
    Created_By = "IaC - Terraform"
  }
}


# Hosted Zone for the Domain (Ensure the domain is registered in AWS Route 53)
resource "aws_route53_zone" "main_zone" {
  name = var.domain_name
}

# Route 53 Record for ACM Validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.my_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.main_zone.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}


output "route53_zone_id" {
  value = aws_route53_zone.main_zone.zone_id
}

output "certificate_arn" {
  value = aws_acm_certificate.my_cert.arn
}

# Create S3 Bucket in ap-south-2 region
resource "aws_s3_bucket" "static_site_primary" {
  bucket = "www.hayagreevatechsolutions.in"

}

resource "aws_s3_bucket_versioning" "hgts_primary_version" {
  bucket = aws_s3_bucket.static_site_primary.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "hgts_primary_public_access" {
  bucket = aws_s3_bucket.static_site_primary.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

output "static_site_primary" {
  value = aws_s3_bucket.static_site_primary.id
}


# Create S3 Bucket in ap-south-2 region
resource "aws_s3_bucket" "hgts_static_site_redirect" {
  bucket = "hayagreevatechsolutions.in"

}

resource "aws_s3_bucket_versioning" "hgts_redirect_version" {
  bucket = aws_s3_bucket.hgts_static_site_redirect.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "hgts_redirect_public_access" {
  bucket = aws_s3_bucket.hgts_static_site_redirect.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

output "hgts_static_site_redirect" {
  value = aws_s3_bucket.hgts_static_site_redirect.id
}


# Create S3 Bucket in ap-south-2 region
resource "aws_s3_bucket" "hgts_pipeline_artifact" {
  bucket = "hgts-codepipeline-artifacts"

}

resource "aws_s3_bucket_versioning" "hgts_pipeline_version" {
  bucket = aws_s3_bucket.hgts_pipeline_artifact.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "hgts_pipeline_public_access" {
  bucket = aws_s3_bucket.hgts_pipeline_artifact.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

output "hgts_pipeline_artifact" {
  value = aws_s3_bucket.hgts_pipeline_artifact.id
}


# CodeBuild IAM Role
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
    }]
  })
}

# To Create CI/CD Pipeline - CodeBuild
resource "aws_codebuild_project" "build" {
  name         = "hgts-codebuild"
  service_role = aws_iam_role.codebuild_role.arn
  source {
    type     = "GITHUB"
    location = "https://github.com/kesavkummari/hgts.git"
  }
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:5.0"
    type         = "LINUX_CONTAINER"
  }
}

resource "aws_codepipeline" "pipeline" {
  name     = "hgts-pipeline"
  role_arn = aws_iam_role.codebuild_role.arn

  artifact_store {
    location = aws_s3_bucket.hgts_pipeline_artifact.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        Owner      = "kesavkummari"
        Repo       = "hgts"
        Branch     = "main"
        OAuthToken = "<GITHUB_TOKEN>"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }
}

resource "aws_db_instance" "rds" {
  engine              = "postgres"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  db_name             = "hgts"
  username            = "hgts_usr"
  password            = "P@ssword"
  publicly_accessible = true
  skip_final_snapshot = true
}
