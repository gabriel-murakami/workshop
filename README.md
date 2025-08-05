# 🛠️ Workshop API (Rails + Docker)

Este projeto é uma aplicação **Ruby on Rails (API only)** containerizada com **Docker**, utilizando **PostgreSQL** como banco de dados.

## 🚀 Comandos disponíveis
```bash
make setup     # Builda a imagem do projeto e faz a configuração do banco
make build     # Builda a imagem do projeto
make up        # Sobe os containers em segundo plano (detached)
make down      # Derruba os containers e remove órfãos
make db-create # Cria e migra o banco de dados
make console   # Acessa o console Rails
make server    # Inicia o servidor Rails
make spec      # Roda os testes unitários
make bash      # Acessa o bash do container web
```
