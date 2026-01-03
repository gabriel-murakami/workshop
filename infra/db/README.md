# workshop-db (Terraform)

Contrato de infraestrutura para provisionar um **Amazon RDS PostgreSQL** privado, acessível **somente** a partir dos **nodes do EKS** (via Security Group do node group) dentro da VPC do cluster.

## O que este stack cria

- `aws_db_instance` PostgreSQL (porta 5432), **não público** (`publicly_accessible = false`)
- `aws_db_subnet_group` usando **subnets privadas** do cluster
- `aws_security_group` permitindo **ingress 5432** a partir do **Security Group dos nodes do EKS**

Este stack **depende do remote state** do stack do cluster (VPC/EKS) para obter:
- `vpc_id`
- `private_subnets`
- `node_security_group_id`

## Pré-requisitos

- Terraform `>= 1.5.0`
- Credenciais AWS configuradas (ex.: `AWS_PROFILE`, `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`, ou role via SSO)
- Um stack anterior (cluster) publicado em S3 (remote state) que exporte os outputs citados acima

## Backend (state remoto)

O backend está declarado como S3, mas a configuração é fornecida no `terraform init`:

Exemplo (recomendado) com arquivo `backend.hcl` (você cria localmente):

```hcl
bucket         = "meu-bucket-terraform-state"
key            = "workshop/db/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "meu-lock-table" # opcional, mas recomendado
encrypt        = true
```

Inicialização:

```bash
terraform init -backend-config=backend.hcl
```

## Como usar

1) Crie um arquivo de variáveis (ex.: `terraform.tfvars`):

```hcl
# Região onde o RDS será criado
aws_region = "us-east-1"

# Prefixo para nomear recursos
name_prefix = "workshop"

# Remote state do cluster (EKS/VPC)
cluster_state_bucket = "meu-bucket-terraform-state"
cluster_state_key    = "workshop/cluster/terraform.tfstate"
cluster_state_region = "us-east-1"

# Se o state do cluster usa lock/role, configure conforme necessário
# cluster_state_dynamodb_table = "meu-lock-table"  # opcional
# cluster_state_role_arn       = "arn:aws:iam::123456789012:role/minha-role" # opcional

# Banco
# database_username = "postgres" # default
# db_name           = "workshop_production" # default

database_password = "TROQUE-ESTA-SENHA" # obrigatório

# tags = { project = "workshop" } # default
```

2) Planejar e aplicar:

```bash
terraform plan  -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Variáveis (contrato)

### Obrigatórias

- `cluster_state_bucket` (string): bucket S3 onde está o state do cluster
- `cluster_state_key` (string): chave do objeto do state do cluster
- `database_password` (string, **sensitive**): senha do usuário do Postgres

### Opcionais (com defaults)

- `aws_region` (string, default: `us-east-1`)
- `name_prefix` (string, default: `workshop`)
- `cluster_state_region` (string, default: `us-east-1`)
- `cluster_state_dynamodb_table` (string|null, default: `null`) — lock do remote state do cluster
- `cluster_state_role_arn` (string|null, default: `null`) — role para ler o remote state do cluster

Configuração do RDS:

- `database_username` (string, default: `postgres`)
- `db_name` (string, default: `workshop_production`)
- `db_engine_version` (string, default: `15.5`)
- `db_instance_class` (string, default: `db.t4g.micro`)
- `db_allocated_storage` (number, default: `20`)
- `db_multi_az` (bool, default: `false`)
- `db_backup_retention_days` (number, default: `7`)
- `db_deletion_protection` (bool, default: `false`)
- `db_skip_final_snapshot` (bool, default: `true`)
- `tags` (map(string), default: `{ project = "workshop" }`)

## Outputs

- `rds_address`: endpoint DNS do RDS
- `rds_port`: porta (5432)
- `rds_db_name`: nome do database
- `rds_security_group_id`: Security Group do RDS

## Segurança e conectividade

- O RDS é criado em **subnets privadas** e com `publicly_accessible = false`.
- O SG do RDS permite acesso **somente** do `node_security_group_id` vindo do remote state do cluster.
- Para conectar a partir do seu computador, use um caminho dentro da VPC (ex.: bastion, SSM, VPN) — não existe acesso direto público.

## Notas operacionais

- `database_password` é marcado como **sensitive**, mas ainda assim evite commitar `terraform.tfvars` com senha.
- Se `db_skip_final_snapshot = true` e `db_deletion_protection = false`, destruir o recurso pode **perder dados**. Ajuste para ambientes que precisam de retenção.
