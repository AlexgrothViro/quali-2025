#!/usr/bin/env bash
set -euo pipefail

DB_DIR="db"
DATA_DIR="data"
RAW_FASTA="$(mktemp)"
FASTA="${DB_DIR}/ptv_teschovirus.fasta"
REF_FASTA="${DATA_DIR}/ptv_db.fa"
DB_PREFIX="${DB_DIR}/ptv_teschovirus"
trap 'rm -f "$RAW_FASTA"' EXIT

# Query focada em Teschovirus A (Porcine Teschovirus) com genoma completo
QUERY='"Teschovirus A"[Organism] AND "complete genome"[Title]'

echo "========================================="
echo "  Construção do banco BLAST de PTV"
echo "  (Porcine Teschovirus / Teschovirus A)"
echo "========================================="
echo
echo "Diretório do banco: ${DB_DIR}"
echo "Arquivo FASTA (DB):  ${FASTA}"
echo "FASTA para scripts:  ${REF_FASTA}"
echo "Prefixo do DB:      ${DB_PREFIX}"
echo
echo "Query NCBI:"
echo "  ${QUERY}"
echo

mkdir -p "$DB_DIR" "$DATA_DIR"

echo "[$(date)] Buscando sequências no NCBI..."
esearch -db nucleotide -query "$QUERY" | efetch -format fasta > "$RAW_FASTA"

if [[ ! -s "$RAW_FASTA" ]]; then
  echo "ERRO: arquivo FASTA temporário (${RAW_FASTA}) está vazio. Verifique a query, suas credenciais NCBI ou a conexão." >&2
  exit 1
fi

echo "[$(date)] Normalizando headers (apenas primeiro token)..."
python3 - <<'PY'
import sys

def normalize_headers(src, dst):
    with open(src) as inp, open(dst, "w") as out:
        cur = []
        header = None
        for line in inp:
            line = line.strip()
            if not line:
                continue
            if line.startswith(">"):
                if header is not None:
                    out.write(">" + header + "\n")
                    out.write("\n".join(cur) + "\n")
                header = line[1:].split()[0]
                cur = []
            else:
                cur.append(line.replace(" ", "").replace("\t", ""))
        if header is not None:
            out.write(">" + header + "\n")
            out.write("\n".join(cur) + "\n")

normalize_headers(sys.argv[1], sys.argv[2])
PY
"$RAW_FASTA" "$FASTA"

cp "$FASTA" "$REF_FASTA"
rm -f "$RAW_FASTA"

if [[ ! -s "$FASTA" ]]; then
  echo "ERRO: arquivo FASTA ${FASTA} está vazio após normalização." >&2
  exit 1
fi

echo "[$(date)] FASTA salvo em: ${FASTA}"
echo "Cópia para scripts salva em: ${REF_FASTA}"
echo "Pré-visualização das primeiras linhas:"
head -n 5 "$FASTA" || true
echo

echo "[$(date)] Construindo banco BLAST com makeblastdb..."
makeblastdb -in "$FASTA" -dbtype nucl -out "$DB_PREFIX"

echo
echo "[$(date)] Banco BLAST construído com sucesso."
echo "Arquivos gerados em: ${DB_DIR}"
echo
echo "Para usar este banco no pipeline, execute:"
echo "  export BLAST_DB=\"$(pwd)/${DB_PREFIX}\""
