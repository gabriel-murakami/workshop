import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 20 },
    { duration: '1m', target: 50 },
    { duration: '1m', target: 100 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<800'],  // 95% das requisições abaixo de 800ms
    http_req_failed: ['rate<0.05'],    // menos de 5% de falhas
  },
};

const BASE_URL = 'http://localhost:3000';
const USER_CREDENTIALS = {
  email: 'admin@admin.com',
  password: 'password123',
};

function authenticate() {
  const res = http.post(`${BASE_URL}/login`, JSON.stringify(USER_CREDENTIALS), {
    headers: { 'Content-Type': 'application/json' },
  });

  check(res, {
    'status 200': (r) => r.status === 200,
  });

  if (!res.body || res.body.length === 0) {
    console.error(`Login falhou ou retornou corpo vazio. Status: ${res.status}`);
    return null;
  }

  let token;
  try {
    token = res.json('token');
  } catch (err) {
    console.error('Erro ao parsear JSON da resposta de login:', err);
    return null;
  }

  if (!token) {
    console.error('Token não encontrado na resposta do login');
    return null;
  }

  return token;
}

// Função principal de teste
export default function () {
  const token = authenticate();
  if (!token) {
    return;
  }

  for (let i = 0; i < 10; i++) {
    const res = http.get(`${BASE_URL}/service_orders`, {
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
    });

    check(res, {
      'status 200': (r) => r.status === 200,
    });

    if (!res.body || res.body.length === 0) {
      console.warn(`Requisição /service_orders retornou corpo vazio. Status: ${res.status}`);
    }

    sleep(1);
  }
}
