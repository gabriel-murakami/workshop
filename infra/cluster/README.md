# workshop-infra (contrato)

Infraestrutura AWS via Terraform para um ambiente de workshop com:

- **VPC** (subnets públicas/privadas + NAT)
- **EKS** (managed node group)
- **ECR** (repositório para a aplicação)

> Este repositório define o **contrato** de entrada (variáveis) e saída (outputs) da infra. Ele não inclui deployment da aplicação no cluster.

## Pré-requisitos

- Terraform **>= 1.5.0** (ver [backend.tf](backend.tf))
- Credenciais AWS configuradas (ex.: `AWS_PROFILE`/`AWS_ACCESS_KEY_ID` etc.) com permissões para criar VPC/EKS/ECR e recursos do backend
- Um backend remoto (recomendado): **S3** para state + **DynamoDB** para lock (ver [backend.tf](backend.tf))

## Como usar

### 1) Inicializar o backend

O backend está declarado como `s3`, mas a configuração (bucket, key, region, dynamodb_table) é passada no `terraform init`.

Exemplo (ajuste para seu ambiente):

```bash
terraform init \
  -backend-config="bucket=SEU_BUCKET_DE_STATE" \
  -backend-config="key=workshop/infra/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=SUA_TABELA_DE_LOCK" \
  -backend-config="encrypt=true"
```

### 2) Planejar e aplicar

```bash
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

### 3) Configurar acesso ao cluster (kubectl)

Depois do `apply`, atualize o kubeconfig (exemplo):

```bash
aws eks update-kubeconfig --region us-east-1 --name workshop-eks
kubectl get nodes
```

> Dica: você pode obter `region` e `cluster_name` via `terraform output`.

### 4) Usar o ECR

Após o `apply`, os outputs incluem o repositório e a URL:

```bash
terraform output ecr_repository_url
```

Login no ECR (exemplo):

```bash
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "$(terraform output -raw ecr_repository_url | cut -d/ -f1)"
```

## Inputs (variáveis)

Definidas em [variables.tf](variables.tf).

| Variável | Tipo | Padrão | Descrição |
|---|---|---:|---|
| `aws_region` | string | `us-east-1` | Região AWS para provisionamento. |
| `cluster_name` | string | `workshop-eks` | Nome do cluster EKS. |
| `kubernetes_version` | string | `1.29` | Versão do Kubernetes no EKS. |
| `vpc_name` | string | `workshop-vpc` | Nome da VPC. |
| `vpc_cidr` | string | `10.0.0.0/16` | Bloco CIDR da VPC. |
| `public_subnets` | list(string) | `10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24` | Subnets públicas (3 AZs). |
| `private_subnets` | list(string) | `10.0.10.0/24, 10.0.11.0/24, 10.0.12.0/24` | Subnets privadas (3 AZs). |
| `node_instance_types` | list(string) | `t3.medium` | Tipos de instância do node group. |
| `node_min_size` | number | `1` | Mínimo de nós. |
| `node_max_size` | number | `3` | Máximo de nós. |
| `node_desired_size` | number | `2` | Desejado de nós. |
| `ecr_repository` | string | `workshop-api` | Nome do repositório ECR. |
| `tags` | map(string) | `{ project = "workshop" }` | Tags aplicadas aos recursos. |

### Como sobrescrever variáveis

- Via arquivo `.tfvars`:

```bash
terraform apply -var-file="env/dev.tfvars"
```

- Via `-var` (rápido para testes):

```bash
terraform apply -var="cluster_name=meu-eks" -var="aws_region=us-east-1"
```

## Outputs

Definidos em [outputs.tf](outputs.tf):

- `aws_region`
- `cluster_name`
- `cluster_endpoint`
- `vpc_id`
- `private_subnets`
- `public_subnets`
- `node_security_group_id`
- `ecr_repository`
- `ecr_repository_url`

## Arquitetura (resumo)

- VPC criada via `terraform-aws-modules/vpc/aws` (NAT habilitado, 1 NAT gateway)
- Subnets com tags para integração com EKS (ELB e internal ELB)
- EKS criado via `terraform-aws-modules/eks/aws` com node group gerenciado (`default`)
- ECR com scan on push habilitado

## Destroy

Para remover tudo:

```bash
terraform destroy
```

## Notas importantes

- **State** não deve ser commitado. O `.terraform/` já está ignorado em [.gitignore](.gitignore). Recomenda-se backend remoto (S3/DynamoDB) para colaboração.
- O endpoint do cluster está habilitado publicamente (`cluster_endpoint_public_access = true`). Ajuste conforme sua política de rede/segurança.
