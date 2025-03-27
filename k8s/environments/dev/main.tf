terraform {
  backend "s3" {
    bucket         = "hgts-tf-statefiles"
    key            = "k8s-dev-terraform.tfstate"
    region         = "ap-south-2"
    dynamodb_table = "hgts-terraform"
    profile = "terraform-automation"
    #profile = "hgts"
  }
}

provider "aws" {
  # assume_role {
  #   role_arn = "arn:aws:iam::${var.aws_account_id}:role/terraform-automation"
  # }
  region = var.region
}

data "terraform_remote_state" "hgts_preprod_vpc" {
  backend = "s3"

  config = {
    bucket = "hgts-tf-statefiles"
    key    = "k8s-infra-terraform.tfstate"
    region = "ap-south-2"
  }
}


module "hgts_dev" {
  source = "../../modules/hgts/hgts-website"

  # App Instance Inputs
  hgts_web_vpc_id              = data.terraform_remote_state.hgts_preprod_vpc.outputs.vpc_id
  hgts_web_public_subnets     = data.terraform_remote_state.hgts_preprod_vpc.outputs.public_subnet_1
  hgts_web_private_subnets     = data.terraform_remote_state.hgts_preprod_vpc.outputs.private_subnet_1
  hgts_web_data_subnets        = data.terraform_remote_state.hgts_preprod_vpc.outputs.data_subnet_1

  ec2_policy_for_ssm           = var.ec2_policy_for_ssm
  hgts_web_additional_tags     = var.global_tags
  hgts_web_environment         = "dev"
  hgts_web_key_name            = data.terraform_remote_state.hgts_preprod_vpc.outputs.keypair
  hgts_web_admin_web_sg_id     = data.terraform_remote_state.hgts_preprod_vpc.outputs.web_sg
  hgts_web_admin_windows_sg_id = data.terraform_remote_state.hgts_preprod_vpc.outputs.windows_sg
  hgts_web_admin_windows_sg_id = data.terraform_remote_state.hgts_preprod_vpc.outputs.linux_sg

  hgts_web_app_instance_size   = "t3.medium"
  hgts_web_global_source_cidrs = ["10.0.0.0/8"]

}


