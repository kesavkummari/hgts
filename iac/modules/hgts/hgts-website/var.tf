variable "hgts_web_vpc_id" {}

# variable "hgts_web_private_subnets" { type = list}

# variable "hgts_web_data_subnets" { type = list}

variable "hgts_web_private_subnets" { 
  type = string
  }

# variable "hgts_web_data_subnets" { 
#     type = string
# }


variable "hgts_web_data_subnets" {
  type        = string
  description = "Private subnet ID from AZ-1"
}

variable "hgts_web_data_subnets_2" {
  type        = string
  description = "Private subnet ID from AZ-2"
}


variable "ec2_policy_for_ssm" {}

variable "hgts_web_global_source_cidrs" { type = list}

variable "hgts_web_ami" {
  default = "ami-0ae47cb7b24e2d8ed"  //0
}

variable "hgts_web_app_ami" {
  default = "ami-0910dac3efe29f09d"  //Microsoft Windows 2025 Datacenter edition
}

variable "hgts_web_root_volume_size" {
  default = 10
}

variable "hgts_web_instance_size" {
  default = "t3.micro"
}

variable "hgts_web_app_c_volume_size" {
  default = 50
}
 
 
variable "hgts_web_app_instance_size" {
  default = "t3.micro"
}

variable "hgts_web_key_name" {}

variable "hgts_web_rdp_cidrs" {
  type    = list
  default = []
}

variable "hgts_web_environment" {}

variable "hgts_web_additional_tags" {
  type = map
}

variable "hgts_web_resource_name_prepend" {
  default = "hgts"
}

variable "hgts_web_hosted_zone_id" {
  default = ""
}

variable "hgts_web_setup_dns" {
  default = false
}

variable "hgts_web_module_tags" {
  type = map
  default = {
    "Application"  = "hgts"
    "ContactEmail" = "support@c3ops.in"
    "Business"="Cloud"
  }
}

variable "hgts_web_assign_eip" {
  default = false
}

variable "hgts_web_admin_web_sg_id" {}

variable "hgts_web_admin_windows_sg_id" {}

# RDS Instance Variables
/////////////////////////////////////////////////////////////////

variable "rds_instance_identifier" {
  description = "Custom name of the instance"
}

variable "rds_is_multi_az" {
  description = "Set to true on production"
  default     = false
}

variable "rds_storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD)."
  default     = "standard"
}

variable "rds_iops" {
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of 'io1', default is 0 if rds storage type is not io1"
  default     = "0"
}

variable "rds_allocated_storage" {
  description = "The allocated storage in GBs"

  # You just give it the number, e.g. 10
}

variable "rds_snapshot_identifier" {
  description = "snapshot to restore"
  default = "none"
}

variable "rds_engine_type" {
  description = "Database engine type"
  default     = "postgres"
  # Valid types are
  # - mysql
  # - postgres
  # - oracle-*
  # - sqlserver-*
  # - sqlserver-ex
  # See http://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html
  # --engine
}

variable "rds_engine_version" {
  description = "Database engine version, depends on engine type"
  default     = "17.4"
  # For valid engine versions, see:
  # See http://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html
  # --engine-version
}

variable "rds_instance_class" {
  description = "Class of RDS instance"
  default     = "db.t4g.micro"
  # Valid values
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
}

//variable "rds_snapshot_identifier" {
//  description = "The snapshot to restore the rds instance"
//}

variable "rds_subnet_group" {
  description = "The rds subnet group"
  default = "hgts-db-subnet"
}

variable "rds_admin_sg" {
  description = "The admin rds security group"
}

variable "auto_minor_version_upgrade" {
  description = "Allow automated minor version upgrade"
  default     = false
}

variable "allow_major_version_upgrade" {
  description = "Allow major version upgrade"
  default     = false
}

variable "apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
  default     = false
}

variable "maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi' UTC "
  default     = "Mon:03:00-Mon:04:00"
}

variable "database_name" {
  description = "The name of the database to create"
  default     = "hgts-web"
}

//# Self-explainatory variables
variable "database_user" {}

variable "database_password" {}

variable "database_port" {}

# This is for a custom parameter to be passed to the DB
# We're "cloning" default ones, but we need to specify which should be copied
variable "db_parameter_group" {
  description = "Parameter group, depends on DB engine used"
  default = "postgres9.5"
  # default = "mysql5.6"
  # default = "postgres9.5"
}

variable "publicly_accessible" {
  description = "Determines if database can be publicly available (NOT recommended)"
  default     = true 
}

variable "skip_final_snapshot" {
  description = "If true (default), no snapshot will be made before deleting DB"
  default     = true
}

variable "copy_tags_to_snapshot" {
  description = "Copy tags from DB to a snapshot"
  default     = true
}

variable "backup_window" {
  description = "When AWS can run snapshot, can't overlap with maintenance window"
  default     = "22:00-03:00"
}

variable "backup_retention_period" {
  type        = string
  description = "How long will we retain backups"
  default     = 0
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

////////////////////////////////////////////////////////////