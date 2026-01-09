# Workshop API

Este projeto implementa um sistema completo para gerenciamento de oficinas mecânicas, possibilitando o controle de ordens de serviço, cadastro de clientes e seus veículos, além do gerenciamento de peças, insumos e geração de orçamentos.

## Tecnologias
- Ruby on Rails 7.2.2
- PostgreSQL 15
- RSpec para testes
- Brakeman para análise de segurança
- Simplecov para análise de cobertura de testes
- Docker para containerização

## Estrutura

- `application/..`: orquestram os casos de uso dos domínios (`*_application.rb`) e os objetos que representam os comandos do sistemas (`application/commands/*_command.rb`).
- `domain/..`: contém as regras de negócio, onde serão aplicadas as lógicas de cada entidade do sistema.
- `infra/..`: responsável por acessar os dados (`/repositories`) e realizar consultas complexas (`/query_objects`)
- `web/..`: responsável pela interação com o usuário através de APIs (`/controllers`)

```bash
.
├── layers
│   ├── application                      # Camada de aplicação
│   │   ├── <context_domain_1>           # Ex: customer, service_order, service_order_item
│   │   │   ├── commands                 # Objetos que representam ações ou operações do sistema (ex: CreateCustomerCommand)
│   │   │   ├── <context>_application.rb # Serviço de aplicação que orquestra casos de uso do domínio
│   │   │   └── ...
│   │   └── ...
│   │
│   ├── domain                 # Camada de domínio: entidades e regras de negócio
│   │   ├── <context_domain_1> # Ex: customer, service_order, service_order_item
│   │   │   ├── entidade.rb    # Exemplo: customer.rb, representando entidade com lógica e regra de negócio
│   │   │   └── ...
│   │   └── ...
│   │
│   ├── infra                         # Infraestrutura técnica para persistência, filas, jobs etc.
│   │   ├── models                    # Representação ORM dos dados
│   │   │   └── application_record.rb # Classe base para models ORM; todos os models herdam dela
│   │   ├── repositories              # Abstração para acesso a dados (ex: CustomerRepository)
│   │   ├── query_objects             # Consultas especializadas para recuperar dados complexos
│   │   ├── jobs                      # Processos assíncronos e background jobs
│   │   └── ...
│   │
│   ├── web             # Camada de apresentação (HTTP)
│   │   ├── controllers # Controladores que processam requisições e delegam para application
│   │   └── concerns    # Módulos reutilizáveis para controllers (Ex: autenticação)
│   └── serializers     # Camada de apresentação (Serialização)
│       ├── <context_domain_1>
│       └── <entidade>_serializer.rb # Classe contendo as regras de serialização da entidade
```

## Execução e Documentação:
```bash
ln -s .env.example .env
make setup
make server
```
É possível consultar a documentação da API com **Swagger** em:
```
http://localhost:3000/api-docs/index.html
```

#### **Collection para as APIs**: [Insomnia](docs/collection.yaml)

## Testes e Cobertura
```bash
make test
```

Esse comando rodará os testes e imprimirá no console o resultado.

Exemplo:
```bash
Finished in 1.09 seconds (files took 2.35 seconds to load)
76 examples, 0 failures

Coverage report generated for RSpec to /app/coverage.
Line Coverage: 98.27% (910 / 926)

COVERAGE:  98.27% -- 910/926 lines in 71 files

...
```

Além disso, é gerado um arquivo em `/coverage/index.html` contendo o relatório completo. Esse arquivo também está disponível pós a execução da pipeline do Github Actions do repositório.

## Kubernetes
```shell
# Opcional: limpar pods antigos
kubectl delete deployments,services,secrets,configmaps --all

### Aplicar as configurações:
kubectl apply -f k8s/

### Verificar pods
kubectl get pods -w

### Acessar o pod:
kubectl exec -it deployment/web-deployment -- /bin/bash

### Rodar as migrations:
kubectl exec -it deployment/web-deployment -- bundle exec rake db:migrate

### Criar os seeds:
kubectl exec -it deployment/web-deployment -- bundle exec rake db:seed

### Reiniciar pods:
kubectl rollout restart deployment web-deployment

### (Local) Disponibilizar External IP
minikube tunnel
```

## Terraform
Antes de tudo é necessário iniciar o minikube com `minikube start`
```shell
# Ir para o diretório de infra
cd infra/

# Iniciar o terraform
terraform init

# Opcional: Destruir os recursos antigos
terraform destroy

# Visualizar o plano de criação dos recursos
terraform plan

# Aplicar as configurações dos recursos
terraform apply

# (Local) Disponibilizar External IP
minikube tunnel
```

## Provisionamento por Repositório
```mermaid
flowchart LR
    %% =====================
    %% REPOSITÓRIOS
    %% =====================
    subgraph INFRA["workshop-infra"]
        I1["Infra Pull Request"]
        I2["Terraform Apply
        (NGINX, Ingress, Datadog)"]
    end

    subgraph DB["workshop-db"]
        D1["DB Pull Request"]
        D2["Terraform Apply
        (Postgres, Secrets)"]
    end

    subgraph AUTH["workshop-auth-lambda"]
        A1["Auth Pull Request"]
        A2["Build Image"]
        A3["Push GHCR"]
        A4["Deploy Knative Service"]
    end

    subgraph API["workshop (Rails API)"]
        R1["API Pull Request"]
        R2["Build Image"]
        R3["Push GHCR"]
        R4["Deploy Deployment + Service + HPA"]
    end

    %% =====================
    %% FLUXO POR REPO
    %% =====================
    I1 --> I2
    D1 --> D2
    A1 --> A2 --> A3 --> A4
    R1 --> R2 --> R3 --> R4

    %% =====================
    %% CLUSTER
    %% =====================
    subgraph CLUSTER["Kubernetes Cluster"]
        G["NGINX Gateway"]
        DD["Datadog Agent"]
        AUTHRT["Auth Function (Knative)"]
        APIRT["Rails API"]
        DBRT["PostgreSQL"]
    end

    %% =====================
    %% CONVERGÊNCIA NO CLUSTER
    %% =====================
    I2 --> G
    I2 --> DD
    A4 --> AUTHRT
    R4 --> APIRT
    D2 --> DBRT

```

## Diagrama de Componentes
```mermaid
flowchart LR
    subgraph Cloud["Cloud / Infraestrutura"]
        subgraph K8s["Kubernetes Cluster (Minikube)"]
            NGINX["NGINX Ingress Gateway"]

            subgraph Auth["Auth Serverless"]
                AUTH["auth-function (Knative)"]
            end

            subgraph API["Aplicação"]
                WEB["Rails API"]
                HPA["HPA"]
                HPA --> WEB
            end

            subgraph DB["Persistência"]
                POSTGRES["PostgreSQL"]
            end

            subgraph Obs["Observabilidade"]
                DD["Datadog Agent"]
            end
        end
    end

    Client["Cliente / Frontend / HTTP Client"]

    Client --> NGINX
    NGINX --> AUTH
    AUTH --> NGINX
    NGINX --> WEB
    WEB --> POSTGRES

    DD --> NGINX
    DD --> AUTH
    DD --> WEB
    DD --> POSTGRES
```

## Diagrama de Sequência
```mermaid
sequenceDiagram
    participant Client as Cliente
    participant NGINX as NGINX Ingress
    participant AUTH as Auth Function (Knative)
    participant API as Rails API
    participant DB as PostgreSQL

    %% =====================
    %% ETAPA 1 - AUTENTICAÇÃO
    %% =====================
    Client->>NGINX: POST /auth (CPF)
    NGINX->>AUTH: Forward /auth

    AUTH->>API: GET /internal/users?cpf
    API->>DB: Busca usuário por CPF
    DB-->>API: Usuário encontrado e ativo
    API-->>AUTH: Status OK

    AUTH-->>NGINX: 200 OK + JWT
    NGINX-->>Client: 200 OK + JWT

    %% =====================
    %% ETAPA 2 - USO DA API
    %% =====================
    Client->>NGINX: POST /service_orders/open (Authorization: Bearer JWT)
    NGINX->>AUTH: auth_request (/auth/validate)

    AUTH-->>NGINX: 200 OK + Headers (X-User-Id, X-User-CPF)
    NGINX->>API: Forward request autorizado

    API->>DB: Cria ordem de serviço
    DB-->>API: Ordem persistida

    API-->>NGINX: 201 Created
    NGINX-->>Client: 201 Created + Payload

```

## Diagrama das Tabelas do Banco
![Diagrama ER](docs/diagram.svg)
