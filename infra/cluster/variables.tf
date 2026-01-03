variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# When true, Terraform will NOT create a new EKS cluster/VPC; it will instead
# reference an existing cluster (by cluster_name) and create/manage only the
# node group resources.
variable "use_existing_cluster" {
  type    = bool
  default = false
}

variable "cluster_name" {
  type    = string
  default = "workshop-cluster"
}

variable "kubernetes_version" {
  type    = string
  default = "1.29"
}

variable "vpc_name" {
  type    = string
  default = "workshop-vpc"
}

# If set, the configuration will reuse an existing VPC instead of creating a new one.
variable "existing_vpc_id" {
  type    = string
  default = ""
}

# Private subnet IDs used by the EKS cluster/node groups when reusing an existing VPC.
variable "existing_private_subnet_ids" {
  type    = list(string)
  default = []
}

# Optional public subnets (only needed if you want to output/validate them).
variable "existing_public_subnet_ids" {
  type    = list(string)
  default = []
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.small"]
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 3
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "ecr_repository" {
  type    = string
  default = "workshop-api"
}

variable "tags" {
  type    = map(string)
  default = { project = "workshop" }
}
