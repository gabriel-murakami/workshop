#!/bin/bash

# Nome do script: run_hpa_test.sh

set -e  # encerra o script se algum comando falhar

minikube addons enable metrics-server
k6 run /home/murakami/workshop/scripts/test_hpa.js
