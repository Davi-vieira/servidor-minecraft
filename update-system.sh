#!/bin/bash
# ============================================================
#  ATUALIZACAO DO SISTEMA E INSTALACAO DE DEPENDENCIAS
#  Ubuntu Server 24.04.4 LTS
# ============================================================

set -e

GREEN='\033[0;32m'
NC='\033[0m'

echo "[+] Atualizando lista de pacotes..."
sudo apt update -y

echo "[+] Atualizando pacotes instalados..."
sudo apt upgrade -y

echo "[+] Instalando dependencias essenciais..."
sudo apt install -y \
    openjdk-21-jre-headless \
    wget \
    curl \
    nano \
    unzip \
    htop \
    screen \
    jq

echo "[+] Verificando instalacao do Java 21..."
java -version 2>&1 || {
    echo "[-] ERRO: Java 21 nao foi instalado corretamente!"
    exit 1
}

echo -e "${GREEN}[OK] Dependencias instaladas com sucesso.${NC}"
