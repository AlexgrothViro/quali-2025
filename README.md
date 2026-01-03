# Pipeline de montagem e anotação preliminar de Porcine Teschovirus (quali-2025)

Neste repositório estou organizando o pipeline que estou desenvolvendo para a qualificação do meu mestrado em Virologia.  
O foco é montar e anotar **Porcine Teschovirus (Teschovirus A)** a partir de dados de sequenciamento (FASTQ pareado), com:

- **remoção de leituras do hospedeiro** (Sus scrofa),
- **montagem de contigs** com Velvet,
- **BLAST** dos contigs contra um **banco específico de Teschovirus**.

A ideia é ter algo **simples de rodar em qualquer máquina Linux/WSL2**, usando `make` e alguns scripts bash, para poder replicar o fluxo em outros computadores e em outras amostras.

---

## 0. Ambiente e requisitos

Para rodar os testes básicos (`make test`), instale e garanta no `PATH`:

- `velveth`, `velvetg` (Velvet)
- `blastn`, `makeblastdb` (BLAST+)
- `bowtie2`
- `esearch`, `efetch` (EDirect do NCBI)
- `python3`
- **Opcional:** `curl` (usado em alguns downloads HTTP)

Variáveis importantes:

- `BLAST_DB`: caminho *prefixo* do banco BLAST de PTV (sem extensão).  
  Após gerar o banco com `./scripts/10_build_ptv_db.sh`, defina, por exemplo:  
  `export BLAST_DB="$PWD/db/ptv_teschovirus"`

> Se esearch/efetch não estiverem instalados (EDirect), consulte:  
> https://www.ncbi.nlm.nih.gov/books/NBK179288/

## 1. Estrutura do repositório

A organização básica é:

```text
quali-2025/
├── Makefile
├── README.md
├── data/
│   ├── raw/             # FASTQ brutos (.fastq.gz)
│   ├── cleaned/         # reservado para futuros pré-processamentos
│   ├── host_removed/    # FASTQ após remoção de hospedeiro
│   └── assemblies/      # contigs e stats das montagens
├── db/
│   └── .gitkeep         # databases locais (PTV) são gerados por script
├── docs/                # documentação, textos, figuras (futuro)
├── results/
│   ├── qc/              # reservado para QC
│   ├── blast/           # resultados de BLAST (TSV)
│   ├── phylogeny/       # arquivos de filogenia (futuro)
│   └── reports/         # relatórios, tabelas finais (futuro)
└── scripts/
    ├── 00_check_env.sh          # checa se os programas principais estão instalados
    ├── 01_run_velvet.sh         # monta contigs com Velvet
    ├── 02_run_blast.sh          # roda BLAST dos contigs contra o banco de PTV
    ├── 03_filter_host.sh        # filtra leituras do hospedeiro (Sus scrofa) com Bowtie2
    ├── 10_build_ptv_db.sh       # baixa sequências de Teschovirus A (NCBI) e gera banco BLAST
    └── 11_download_sus_scrofa.sh# baixa o genoma do hospedeiro (Sus scrofa) via NCBI/EDirect
