#!/usr/bin/env bash

set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost/api/v1}"
TOKEN="${TOKEN:-eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIwMTllNjk1Mi00YWI4LTcyMzctYTg4Ny0zOGY1MjU0N2ZkYmYiLCJqdGkiOiIxM2FhODk4ODg4N2ZhNmUxNDgwNTdkYzExOTdiYTY5YmY3NzRmMGQ3MGI4ZGIwMjg3ZDJjZmI4ODFjMTMwMDI4NDc4OGYzOGE3NDY4OGE5ZSIsImlhdCI6MTc3OTg4MzU4Ny4wMjUzMTMsIm5iZiI6MTc3OTg4MzU4Ny4wMjUzMjIsImV4cCI6MTgxMTQxOTU4Ni45NDc1OTQsInN1YiI6IjEiLCJzY29wZXMiOltdfQ.HnjkkHbAR-PMSNHe2a-RgUV04E9DWOqTC4DzAM7ZnrcFXXq86UolqbDYHH7qgBqj0JSj3p1fKsZnXG_9h472eyC-AO6fC1X6-yfatyBslt8QSbdHTEJSMFctkZ31Xcuwdc4EytZFUtJUKqhKitFdorjJlMGTlrP0lMdmJhgTsQ1NwXPHpet6kkOWyJVBMtrRpHwq3190hZhkT2XckejrqGtSt2ftLCzd9Y3-O0YvYA0hvvE3PFWQ3nlpFV7mNeV6Rn_ZSyiYRmk1Fz0xAk2r9WDr1Ls8rM3ncfE-S0NzzC4yuhtcp-T3xMBPRN5YoAbLOXHWJZ2T8SjddEL7Y_IFF-vi991ibztLVpXdqoA7Geo9Ll5v5XVLx0yLT5_GPgUuKqLXpuuhqbq3TDdkXWfkBl-VioAalVpFvp9iOaCqp8SVkHkgEs6WAs1CPS5BX7Lv7TE1caAJWHvVYFdjpZAXfps4NcCR9qHCXyShd5kv2QBTBGnxdG5kgYmLE42LG-GHguujogNjsyRPHFrk7dlOVT5qg3qrBRdqITXJ-2pNSmkWCJz7PnU9da1JOLSB-RtJCJ2fz2OITEGlgC4CB2R_6yoVl2GYFTKAaU8_0eg-kn1naQJjv4dixQo2tBysAE7SQeq2JX7ldlv0fc3iQ6FCZlpDa340GF6UpJRAmIttyPU}"
TRACE_ID="${TRACE_ID:-40c71bbb-c676-4f24-83cf-cc725d7d7a00}"
SKIP_IF_EXISTS="${SKIP_IF_EXISTS:-true}"

CATEGORIES=(
  "🏡 Casa - Aluguel"
  "🏡 Casa - Condomínio"
  "🏡 Casa - Contas de luz"
  "🏡 Casa - Água"
  "🏡 Casa - Gás"
  "🏡 Casa - Internet"
  "🏡 Casa - Pequenas manutenções"

  "🥙 Alimentação - Supermercado"
  "🥙 Alimentação - Feiras"
  "🥙 Alimentação - Padarias"
  "🥙 Alimentação - Restaurantes"
  "🥙 Alimentação - Delivery"

  "🚗 Transporte - Combustível"
  "🚗 Transporte - Transporte público"
  "🚗 Transporte - Aplicativos de corrida"
  "🚗 Transporte - Manutenção"
  "🚗 Transporte - Seguro do veículo"

  "🇨🇭 Saúde - Plano de saúde"
  "🇨🇭 Saúde - Consultas"
  "🇨🇭 Saúde - Exames"
  "🇨🇭 Saúde - Medicamentos"

  "📚 Educação - Mensalidades escolares"
  "📚 Educação - Cursos"
  "📚 Educação - Livros"
  "📚 Educação - Materiais"

  "🎭 Lazer - Viagens"
  "🎭 Lazer - Passeios"
  "🎭 Lazer - Cinema"
  "🎭 Lazer - Eventos"
  "🎭 Lazer - Assinaturas de streaming"
  "🎭 Lazer - Hobbies"
  "🎭 Lazer - Academia"

  "👤 Despesas pessoais - Roupas"
  "👤 Despesas pessoais - Calçados"
  "👤 Despesas pessoais - Acessórios"
  "👤 Despesas pessoais - Cuidados pessoais"

  "💳 Fatura - Cartão de crédito"

  "🧾 Tarifas e Impostos - Serviços Financeiros"
  "🧾 Tarifas e Impostos - Encargos e Tarifas"
  "🧾 Tarifas e Impostos - IPVA e Gastos Detran"
  "🧾 Tarifas e Impostos - IPTU"
  "🧾 Tarifas e Impostos - Imposto de Renda"

  "*️⃣ Outras despesas"
)

BUDGETS=(
  "🏡 Casa"
  "🥙 Alimentação"
  "🚗 Transporte"
  "🇨🇭 Saúde"
  "📚 Educação"
  "🎭 Lazer"
  "👤 Despesas pessoais"
  "💳 Fatura"
  "🧾 Tarifas e Impostos"
  "*️⃣ Outras despesas"
)

api_headers=(
  -H "Accept: application/json"
  -H "Authorization: Bearer ${TOKEN}"
  -H "X-Trace-Id: ${TRACE_ID}"
)

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Erro: comando obrigatório não encontrado: $1" >&2
    exit 1
  fi
}

json_escape() {
  python3 -c 'import json,sys; print(json.dumps(sys.argv[1], ensure_ascii=False)[1:-1])' "$1"
}

resource_exists() {
  local endpoint="$1"
  local name="$2"
  local response

  response="$(
    curl -fsS \
      "${api_headers[@]}" \
      "${BASE_URL}/${endpoint}?limit=500" 2>/dev/null || true
  )"

  [[ "$response" == *"\"name\":\"${name}\""* ]]
}

create_category() {
  local name="$1"
  local escaped_name
  local body
  local status

  escaped_name="$(json_escape "$name")"
  body="{\"name\":\"${escaped_name}\",\"notes\":\"Importado via script\"}"

  status="$(
    curl -sS \
      -o /tmp/firefly-category-response.json \
      -w '%{http_code}' \
      -X POST \
      "${api_headers[@]}" \
      -H "Content-Type: application/json" \
      -d "$body" \
      "${BASE_URL}/categories"
  )"

  if [[ "$status" == "200" || "$status" == "201" ]]; then
    echo "Categoria criada: $name"
    return 0
  fi

  if [[ "$status" == "422" ]] && grep -q "already in use" /tmp/firefly-category-response.json; then
    echo "Categoria já existe, pulando: $name"
    return 0
  fi

  echo "Falha ao criar categoria '$name' HTTP $status" >&2
  cat /tmp/firefly-category-response.json >&2
  return 1
}

create_budget() {
  local name="$1"
  local escaped_name
  local body
  local status

  escaped_name="$(json_escape "$name")"
  body="{\"name\":\"${escaped_name}\"}"

  status="$(
    curl -sS \
      -o /tmp/firefly-budget-response.json \
      -w '%{http_code}' \
      -X POST \
      "${api_headers[@]}" \
      -H "Content-Type: application/json" \
      -d "$body" \
      "${BASE_URL}/budgets"
  )"

  if [[ "$status" == "200" || "$status" == "201" ]]; then
    echo "Budget criado: $name"
    return 0
  fi

  if [[ "$status" == "422" ]] && grep -q "already in use" /tmp/firefly-budget-response.json; then
    echo "Budget já existe, pulando: $name"
    return 0
  fi

  echo "Falha ao criar budget '$name' HTTP $status" >&2
  cat /tmp/firefly-budget-response.json >&2
  return 1
}

main() {
  local item

  require_command curl
  require_command python3

  echo "Importando ${#CATEGORIES[@]} categorias para ${BASE_URL}/categories"

  for item in "${CATEGORIES[@]}"; do
    if [[ "$SKIP_IF_EXISTS" == "true" ]] && resource_exists "categories" "$item"; then
      echo "Categoria já existe, pulando: $item"
      continue
    fi

    create_category "$item"
  done

  echo
  echo "Importando ${#BUDGETS[@]} budgets para ${BASE_URL}/budgets"

  for item in "${BUDGETS[@]}"; do
    if [[ "$SKIP_IF_EXISTS" == "true" ]] && resource_exists "budgets" "$item"; then
      echo "Budget já existe, pulando: $item"
      continue
    fi

    create_budget "$item"
  done

  echo
  echo "Importação concluída."
}

main "$@"
