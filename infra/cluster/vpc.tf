data "aws_availability_zones" "available" {}

data "aws_vpc" "selected" {
  count = trimspace(var.existing_vpc_id) != "" ? 1 : 0
  id    = var.existing_vpc_id
}

data "aws_subnets" "private" {
  count = trimspace(var.existing_vpc_id) != "" && length(var.existing_private_subnet_ids) == 0 ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [var.existing_vpc_id]
  }

  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }
}

data "aws_subnets" "public" {
  count = trimspace(var.existing_vpc_id) != "" && length(var.existing_public_subnet_ids) == 0 ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [var.existing_vpc_id]
  }

  filter {
    name   = "tag:kubernetes.io/role/elb"
    values = ["1"]
  }
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  use_existing_vpc = trimspace(var.existing_vpc_id) != ""

  vpc_id = local.use_existing_vpc ? data.aws_vpc.selected[0].id : module.vpc[0].vpc_id

  private_subnet_ids = local.use_existing_vpc ? (
    length(var.existing_private_subnet_ids) > 0 ? var.existing_private_subnet_ids : data.aws_subnets.private[0].ids
  ) : module.vpc[0].private_subnets

  public_subnet_ids = local.use_existing_vpc ? (
    length(var.existing_public_subnet_ids) > 0 ? var.existing_public_subnet_ids : data.aws_subnets.public[0].ids
  ) : module.vpc[0].public_subnets
}

module "vpc" {
  count   = local.use_existing_vpc ? 0 : 1
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = merge(
    var.tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "kubernetes.io/role/elb"                    = 1
    }
  )

  private_subnet_tags = merge(
    var.tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "kubernetes.io/role/internal-elb"           = 1
    }
  )

  tags = var.tags
}
