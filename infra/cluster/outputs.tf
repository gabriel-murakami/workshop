output "aws_region" {
  value = var.aws_region
}

output "cluster_name" {
  value = var.cluster_name
}

output "cluster_endpoint" {
  value = var.use_existing_cluster ? data.aws_eks_cluster.existing[0].endpoint : module.eks[0].cluster_endpoint
}

output "vpc_id" {
  value = local.vpc_id
}

output "private_subnets" {
  value = local.private_subnet_ids
}

output "public_subnets" {
  value = local.public_subnet_ids
}

output "node_security_group_id" {
  value = var.use_existing_cluster ? try(data.aws_eks_cluster.existing[0].vpc_config[0].cluster_security_group_id, null) : module.eks[0].node_security_group_id
}

output "ecr_repository" {
  value = aws_ecr_repository.app.name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}
