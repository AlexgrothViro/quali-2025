#!/usr/bin/env bash
set -euo pipefail

# Programas obrigatórios para os testes básicos
REQUIRED_CMDS=(
  velveth
  velvetg
  blastn
  bowtie2
  makeblastdb
  esearch
  efetch
  python3
)

# Programas opcionais (úteis para download direto via HTTP)
OPTIONAL_CMDS=(curl)

echo "== Verificando programas necessários no PATH =="

MISSING=0
for cmd in "${REQUIRED_CMDS[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    path=$(command -v "$cmd")
    printf "  [OK] %s encontrado em %s\n" "$cmd" "$path"
  else
    echo "  [FALTA] $cmd não está no PATH"
    MISSING=1
  fi
done

for cmd in "${OPTIONAL_CMDS[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    path=$(command -v "$cmd")
    printf "  [OK] %s encontrado em %s (opcional)\n" "$cmd" "$path"
  else
    echo "  [OPCIONAL] $cmd não está no PATH (usado em alguns downloads HTTP)"
  fi
done

echo
if [[ -n "${BLAST_DB:-}" ]]; then
  echo "BLAST_DB está definido como: $BLAST_DB"
  echo "Certifique-se de que os arquivos de índice do BLAST existem nesse caminho."
else
  echo "ATENÇÃO: variável de ambiente BLAST_DB não definida."
  echo "O alvo 'test-blast' do Makefile precisa dela."
  echo "Após rodar ./scripts/10_build_ptv_db.sh defina, por exemplo:" \
    "export BLAST_DB=\"\$PWD/db/ptv_teschovirus\""
fi

# Lembrete específico para EDirect
if ! command -v esearch >/dev/null 2>&1 || ! command -v efetch >/dev/null 2>&1; then
  echo
  echo "EDirect ausente: instale EDirect (scripts esearch/efetch) " \
       "conforme documentação do NCBI: https://www.ncbi.nlm.nih.gov/books/NBK179288/"
fi

if [[ -n "${BLAST_DB:-}" ]]; then
  missing_db_files=()
  for ext in nhr nin nog nsd nsi nsq; do
    file="${BLAST_DB}.${ext}"
    [[ -f "$file" ]] || missing_db_files+=("$file")
  done
  if (( ${#missing_db_files[@]} > 0 )); then
    echo
    echo "ATENÇÃO: índices BLAST ausentes para BLAST_DB:"
    printf '  - %s\n' "${missing_db_files[@]}"
    echo "Gere o banco com ./scripts/10_build_ptv_db.sh ou ajuste BLAST_DB."
  fi
fi

if [[ $MISSING -ne 0 ]]; then
  echo
  echo "Alguns programas estão faltando. Veja a seção 'Ambiente e requisitos' no README.md." >&2
  exit 1
fi

echo
echo "Ambiente básico OK."
