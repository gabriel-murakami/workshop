data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

data "aws_eks_cluster" "existing" {
  count = var.use_existing_cluster ? 1 : 0
  name  = var.cluster_name
}

data "aws_eks_cluster_auth" "existing" {
  count = var.use_existing_cluster ? 1 : 0
  name  = var.cluster_name
}

resource "aws_eks_node_group" "default" {
  count = var.use_existing_cluster ? 1 : 0

  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-default-ng"
  node_role_arn   = data.aws_iam_role.lab_role.arn

  subnet_ids     = local.private_subnet_ids
  instance_types = var.node_instance_types

  scaling_config {
    min_size     = var.node_min_size
    max_size     = var.node_max_size
    desired_size = var.node_desired_size
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-default-ng"
  })
}

module "eks" {
  count   = var.use_existing_cluster ? 0 : 1
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnet_ids

  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      name = "${var.cluster_name}-default-ng"

      create_iam_role = false
      iam_role_arn    = data.aws_iam_role.lab_role.arn

      instance_types = var.node_instance_types

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      tags = merge(var.tags, {
        Name = "${var.cluster_name}-default-ng"
      })
    }
  }

  tags = var.tags
}
