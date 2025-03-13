terraform {
  backend "s3" {
    bucket         = "hgts-tf-statefiles"
    key            = "dev-terraform.tfstate"
    region         = "ap-south-2"
    dynamodb_table = "hgts-terraform"
  }
}

provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/terraform-automation"
  }

  region  = var.region
  version = "~> 3.0"
}

data "terraform_remote_state" "shared_prod_vpc" {
  backend = "s3"

  config = {
    bucket = "hgts-tf-statefiles"
    key    = "terraform.tfstate"
    region = "ap-south-2"
  }
}



module "hgts_web_prod" {
  source = "../../modules/hgts_we"

  # App Instance Inputs
  hgts_web_vpc_id            = data.terraform_remote_state.shared_prod_vpc.outputs.vpc_id
  #hgts_web_public_subnets    = data.terraform_remote_state.shared_prod_vpc.outputs.vpc_public_subnets
  hgts_web_private_subnets   = data.terraform_remote_state.shared_prod_vpc.outputs.vpc_private_subnets
  hgts_web_data_subnets      = data.terraform_remote_state.shared_prod_vpc.outputs.vpc_data_subnets
  ec2_policy_for_ssm        = var.ec2_policy_for_ssm
  hgts_web_additional_tags   = var.global_tags
  hgts_web_environment       = "dev"
  #hgts_web_ssl_certificate   = "arn:aws:acm:us-east-1:739275440360:certificate/863c11e2-3494-47eb-a224-1a9f73a71912"
  hgts_web_key_name          = "hgts-shared-preprod"
  #hgts_web_admin_linux_sg_id = data.terraform_remote_state.shared_prod_vpc.outputs.admin_linux_sg_id
  hgts_web_admin_web_sg_id   = data.terraform_remote_state.shared_prod_vpc.outputs.admin_web_sg_id
  hgts_web_admin_windows_sg_id = module.admin-sg.windows_sg_id
  #hgts_web_source_cidrs      = ["10.0.0.0/8"]

  hgts_web_app_instance_size   = "t2.xlarge"
  #hgts_web_alb_internal        = true  # Set this as true if you want an Internal ALB, false if you want a Public ALB

  hgts_web_global_source_cidrs = ["10.0.0.0/8"]

  # RDS Instance Inputs
  rds_instance_identifier     = "dmt-rds-oracle"
  rds_allocated_storage       = 200
  rds_storage_type            = "gp2"
  rds_instance_class          = "db.m5.xlarge"
  rds_subnet_group            = module.vpc.db_subnet_group
  rds_admin_sg                = module.admin-sg.oracle_sg_id
  database_port               = 1521
  rds_engine_type             = "oracle-se2"
  rds_engine_version          = "19.0.0.0"
  database_user               = "mydb1user"
  database_password           = "uPq5A5NCgM9BI6oiUTRA"
  #database_license_model      = "license-included"
  #database_snapshot_identifier = ""

  backup_window               = "02:00-03:00"
  backup_retention_period     = 14
  maintenance_window          = "sun:04:00-sun:07:00"
  rds_is_multi_az             = false
}