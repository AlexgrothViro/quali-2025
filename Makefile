SHELL := /usr/bin/env bash

SCRIPTS_DIR := scripts

# Parâmetros padrão (podem ser sobrescritos: SAMPLE=... KMER=...)
SAMPLE ?= 81554_S150
KMER   ?= 31

.PHONY: help setup_dirs test-env host-index ptv-db check-blast-db filter-host test-velvet test-blast test

help:
	@echo "Alvos disponíveis:"
	@echo "  make help                 # mostra esta ajuda"
	@echo "  make setup_dirs           # cria a estrutura básica de pastas (data/, results/, docs/)"
	@echo "  make test-env             # verifica se os programas básicos estão instalados"
	@echo "  make ptv-db               # baixa sequências de PTV e constrói o banco BLAST local"
	@echo "  make host-index           # baixa Sus scrofa e cria o índice Bowtie2"
	@echo "  make filter-host          # remove leituras alinhadas ao genoma de Sus scrofa"
	@echo "  make test-velvet          # roda montagem de teste com Velvet usando SAMPLE e KMER"
	@echo "  make test-blast           # roda BLAST dos contigs contra o banco definido em BLAST_DB"
	@echo "  make test                 # executa test-env, filter-host, test-velvet e test-blast em sequência"

setup_dirs:
	mkdir -p data/raw data/cleaned data/host_removed data/assemblies
	mkdir -p results/qc results/blast results/phylogeny results/reports
	mkdir -p docs

test-env:
	$(SCRIPTS_DIR)/00_check_env.sh

host-index:
	@if [[ -f ref/host/sus_scrofa_bt2.1.bt2 ]]; then \
		echo "Índice Bowtie2 já encontrado em ref/host/sus_scrofa_bt2.*.bt2 (pulei build)."; \
	else \
		$(SCRIPTS_DIR)/11_download_sus_scrofa.sh; \
		bowtie2-build ref/host/sus_scrofa.fa ref/host/sus_scrofa_bt2; \
	fi

ptv-db:
	@if compgen -G "db/ptv_teschovirus*.nhr" > /dev/null || compgen -G "db/ptv_teschovirus*.nin" > /dev/null; then \
		echo "Banco BLAST de PTV já encontrado em db/ptv_teschovirus.* (pulei build)."; \
	else \
		$(SCRIPTS_DIR)/10_build_ptv_db.sh; \
	fi

check-blast-db:
	@if [[ -z "$${BLAST_DB:-}" ]]; then \
		echo "ERRO: variável BLAST_DB não definida."; \
		echo "Defina, por exemplo: export BLAST_DB=\"$$PWD/db/ptv_teschovirus\""; \
		echo "Se precisar gerar o banco, rode: make ptv-db"; \
		exit 1; \
	fi
	@if ! compgen -G "$${BLAST_DB}.nhr" > /dev/null && ! compgen -G "$${BLAST_DB}.nin" > /dev/null; then \
		echo "ERRO: banco BLAST não encontrado em $$BLAST_DB (.nhr/.nin)."; \
		echo "Gere com: make ptv-db"; \
		exit 1; \
	fi

filter-host: host-index
	$(SCRIPTS_DIR)/03_filter_host.sh $(SAMPLE)

test-velvet:
	$(SCRIPTS_DIR)/01_run_velvet.sh $(SAMPLE) $(KMER)

test-blast: check-blast-db
	$(SCRIPTS_DIR)/02_run_blast.sh $(SAMPLE) $(KMER)

test: test-env check-blast-db filter-host test-velvet test-blast
