# 🛠️ Workshop API (Rails + Docker)

Este projeto é uma aplicação **Ruby on Rails (API only)** containerizada com **Docker**, utilizando **PostgreSQL** como banco de dados.

## 🚀 Execução e Documentação:
```bash
make setup
make server
```
Com o servidor rodando, a documentação utilizando Swagger estará em:
```
http://localhost:3000/api-docs/index.html
```

## Testes e Cobertura
```bash
make test
```

Esse comando rodará os testes e imprimirá no console o resultado.

Ex:
```bash
Finished in 0.62083 seconds (files took 2.3 seconds to load)
48 examples, 0 failures

Coverage report generated for RSpec to /app/coverage.
Line Coverage: 97.14% (679 / 699)

COVERAGE:  97.14% -- 679/699 lines in 58 files

...
```

Além disso, é gerado um arquivo em `/coverage/index.html` contendo o relatório completo. Esse arquivo também está disponível pós a execução da pipeline do Github Actions do repositório.
