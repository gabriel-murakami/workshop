# Infra (Terraform)

Este repositório está preparado para ser dividido em **dois repositórios Terraform**:

1) `infra/cluster` — VPC + EKS + ECR
2) `infra/db` — RDS PostgreSQL (consome outputs do cluster via `terraform_remote_state`)

A aplicação (este repo) usa GitHub Actions para fazer build/push no ECR e aplicar manifests no EKS.

## Ordem recomendada
1. Aplicar `infra/bootstrap` (cria S3 bucket + DynamoDB locks do state)
2. Aplicar `infra/cluster`
3. Aplicar `infra/db`
4. Configurar `DATABASE_HOST` com `rds_address` no GitHub Actions e rodar deploy

## Backends
Cada stack usa `backend "s3" {}` (configurado via `terraform init -backend-config=...`).

Dica: enquanto você ainda não tiver o bucket S3, dá para validar/formatar sem backend com:
- `terraform -chdir=infra/cluster init -backend=false`
- `terraform -chdir=infra/db init -backend=false`

### Bootstrap (cria bucket + lock table)
A stack `infra/bootstrap` usa state local (padrão) e serve apenas para criar:
- S3 bucket de state
- DynamoDB table para lock

Exemplo:
- `terraform -chdir=infra/bootstrap init`
- `terraform -chdir=infra/bootstrap apply -var state_bucket_name=<SEU_BUCKET_UNICO> -var lock_table_name=terraform-locks`

Exemplo (cluster):
- `terraform -chdir=infra/cluster init -backend-config=bucket=... -backend-config=key=cluster/terraform.tfstate -backend-config=region=us-east-1 -backend-config=dynamodb_table=...`

Exemplo (db):
- `terraform -chdir=infra/db init -backend-config=bucket=... -backend-config=key=db/terraform.tfstate -backend-config=region=us-east-1 -backend-config=dynamodb_table=...`

## Remote state (db → cluster)
A stack `infra/db` precisa saber onde está o state do cluster. Configure:
- `cluster_state_bucket`
- `cluster_state_key`
- `cluster_state_region`
- (opcional) `cluster_state_dynamodb_table`
- (opcional) `cluster_state_role_arn`
