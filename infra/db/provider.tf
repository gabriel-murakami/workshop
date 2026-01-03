terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "cluster" {
  backend = "s3"

  config = merge(
    {
      bucket = var.cluster_state_bucket
      key    = var.cluster_state_key
      region = var.cluster_state_region
    },
    var.cluster_state_dynamodb_table != null ? { dynamodb_table = var.cluster_state_dynamodb_table } : {},
    var.cluster_state_role_arn != null ? { role_arn = var.cluster_state_role_arn } : {}
  )
}

locals {
  vpc_id                 = data.terraform_remote_state.cluster.outputs.vpc_id
  private_subnet_ids     = data.terraform_remote_state.cluster.outputs.private_subnets
  node_security_group_id = data.terraform_remote_state.cluster.outputs.node_security_group_id

  name_prefix = var.name_prefix
}
