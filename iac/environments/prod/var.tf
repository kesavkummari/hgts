variable "region" {
  default = "ap-south-2"
}

variable "aws_account_id" {
  default = "739275440360"
}

variable "environment" {
  default = "shared-prod"
}

variable "global_tags" {
  type = map(string)

  default = {
    "Customer"  = "hgts"
    "CreatedBy" = "cicd-terraform"
  }
}

variable "shared_keypair" {
  default = "hgts-shared-preprod"
}

variable "ec2_policy_for_ssm" {
  default = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}