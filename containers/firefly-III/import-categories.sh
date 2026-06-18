#!/usr/bin/env bash

set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost/api/v1}"
TOKEN="${TOKEN:-COLOQUE_SEU_TOKEN_AQUI}"
TRACE_ID="${TRACE_ID:-40c71bbb-c676-4f24-83cf-cc725d7d7a00}"
SKIP_IF_EXISTS="${SKIP_IF_EXISTS:-true}"

CATEGORIES=(
  "Aluguel"
  "Condomínio"
  "Energia"
  "Água"
  "Gás"
  "Internet"
  "Manutenção Residencial"

  "Supermercado"
  "Feira"
  "Padaria"
  "Restaurante"
  "Delivery"

  "Combustível"
  "Transporte Público"
  "Uber"
  "Manutenção Veículo"
  "Seguro Veículo"

  "Plano de Saúde"
  "Consultas"
  "Exames"
  "Medicamentos"
  "Academia"

  "Mensalidade Escolar"
  "Cursos"
  "Livros"
  "Material Escolar"

  "Viagens"
  "Passeios"
  "Cinema"
  "Eventos"
  "Streaming"
  "Hobbies"

  "Roupas"
  "Calçados"
  "Acessórios"
  "Cuidados Pessoais"

  "Tarifas Bancárias"
  "Juros"
  "IPVA"
  "Detran"
  "IPTU"
  "Imposto de Renda"
)

BUDGETS=(
  "Casa"
  "Alimentação"
  "Transporte"
  "Saúde"
  "Educação"
  "Lazer"
  "Despesas Pessoais"
  "Tarifas e Impostos"
  "Outras despesas"
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
