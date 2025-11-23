SHELL := /usr/bin/env bash

# Diretório onde ficam os scripts do pipeline
SCRIPTS_DIR := scripts

# Parâmetros padrão (podem ser sobrescritos: make test-velvet SAMPLE=... KMER=...)
SAMPLE ?= exemplo
KMER   ?= 31

.PHONY: help setup_dirs test-env test-velvet

help:
	@echo "Alvos disponíveis:"
	@echo "  make help                 # mostra esta ajuda"
	@echo "  make setup_dirs           # cria a estrutura básica de pastas (data/, results/, docs/)"
	@echo "  make test-env             # verifica se os programas básicos estão instalados"
	@echo "  make test-velvet          # roda montagem de teste com Velvet usando SAMPLE e KMER"

setup_dirs:
	mkdir -p data/raw data/cleaned data/host_removed data/assemblies
	mkdir -p results/qc results/blast results/phylogeny results/reports
	mkdir -p docs

test-env:
	$(SCRIPTS_DIR)/00_check_env.sh

test-velvet:
	$(SCRIPTS_DIR)/01_run_velvet.sh $(SAMPLE) $(KMER)
