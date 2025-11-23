SHELL := /usr/bin/env bash

# Diretório onde ficam os scripts do pipeline
SCRIPTS_DIR := scripts

.PHONY: help setup_dirs test-env

help:
	@echo "Alvos disponíveis:"
	@echo "  make help         # mostra esta ajuda"
	@echo "  make setup_dirs   # cria a estrutura básica de pastas (data/, results/, docs/)"
	@echo "  make test-env     # verifica se os programas básicos estão instalados"

setup_dirs:
	mkdir -p data/raw data/cleaned data/host_removed data/assemblies
	mkdir -p results/qc results/blast results/phylogeny results/reports
	mkdir -p docs

test-env:
	\$(SCRIPTS_DIR)/00_check_env.sh
