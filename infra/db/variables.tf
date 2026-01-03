variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name_prefix" {
  type    = string
  default = "workshop"
}

# Remote state do repo/stack do cluster (EKS/VPC)
variable "cluster_state_bucket" {
  type = string
}

variable "cluster_state_key" {
  type = string
}

variable "cluster_state_region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_state_dynamodb_table" {
  type    = string
  default = null
}

variable "cluster_state_role_arn" {
  type    = string
  default = null
}

# Config do RDS
variable "database_username" {
  type    = string
  default = "postgres"
}

variable "database_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type    = string
  default = "workshop_production"
}

variable "db_engine_version" {
  type    = string
  default = "15.5"
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_multi_az" {
  type    = bool
  default = false
}

variable "db_backup_retention_days" {
  type    = number
  default = 7
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}

variable "db_skip_final_snapshot" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = { project = "workshop" }
}
