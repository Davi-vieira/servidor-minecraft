#!/bin/bash
# ============================================================
#  INSTALADOR MESTRE - SERVIDOR MINECRAFT PAPERMC
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MINECRAFT_USER="minecraft"
MC_DIR="/home/$MINECRAFT_USER/minecraft-server"

echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}  INSTALADOR SERVIDOR MINECRAFT PAPERMC     ${NC}"
echo -e "${CYAN}  PaperMC + GeyserMC + Floodgate + AuthMe   ${NC}"
echo -e "${CYAN}  Playit.gg (Tunel de Rede)                 ${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

echo -e "${YELLOW}[1/5] Atualizando sistema...${NC}"
bash "$SCRIPT_DIR/update-system.sh"

echo ""
echo -e "${YELLOW}[2/5] Criando usuario e pastas...${NC}"

if ! id "$MINECRAFT_USER" &>/dev/null; then
    sudo adduser --system --home "/home/$MINECRAFT_USER" --shell /bin/bash "$MINECRAFT_USER"
    sudo addgroup --system "$MINECRAFT_USER" 2>/dev/null || true
    echo -e "${GREEN}  Usuario criado.${NC}"
else
    echo -e "${GREEN}  Usuario ja existe.${NC}"
fi

sudo mkdir -p "$MC_DIR"
sudo chown -R $MINECRAFT_USER:$MINECRAFT_USER "/home/$MINECRAFT_USER"

echo ""
echo -e "${YELLOW}[3/5] Baixando PaperMC e plugins...${NC}"
bash "$SCRIPT_DIR/setup-server.sh"

echo ""
echo -e "${YELLOW}[4/5] Copiando arquivos para $MC_DIR ...${NC}"

# Paper jar
PAPER_JAR=$(find "$SCRIPT_DIR" -maxdepth 1 -name "paper-*.jar" -size +1M 2>/dev/null | head -1)
if [ -n "$PAPER_JAR" ]; then
    sudo cp "$PAPER_JAR" "$MC_DIR/"
    sudo ln -sf "$(basename "$PAPER_JAR")" "$MC_DIR/paper.jar"
    sudo chown $MINECRAFT_USER:$MINECRAFT_USER "$MC_DIR/$(basename "$PAPER_JAR")" "$MC_DIR/paper.jar"
    echo -e "${GREEN}  Paper MC copiado.${NC}"
else
    echo -e "${RED}  Paper MC NAO encontrado! Baixe manualmente.${NC}"
fi

# Plugins da pasta plugins/
if [ -d "$SCRIPT_DIR/plugins" ]; then
    sudo mkdir -p "$MC_DIR/plugins"
    sudo cp "$SCRIPT_DIR/plugins/"*.jar "$MC_DIR/plugins/" 2>/dev/null || true
    sudo chown -R $MINECRAFT_USER:$MINECRAFT_USER "$MC_DIR/plugins/"
    echo -e "${GREEN}  Plugins copiados.${NC}"
    ls -lh "$MC_DIR/plugins/" 2>/dev/null
fi

# Plugins extras na raiz do script (GriefPrevention, SetHome, etc)
for jar in "$SCRIPT_DIR/GriefPrevention.jar" "$SCRIPT_DIR/SetHome"*.jar; do
    if [ -f "$jar" ]; then
        sudo mkdir -p "$MC_DIR/plugins"
        sudo cp "$jar" "$MC_DIR/plugins/"
        sudo chown $MINECRAFT_USER:$MINECRAFT_USER "$MC_DIR/plugins/$(basename "$jar")"
        echo -e "${GREEN}  Plugin extra copiado: $(basename "$jar")${NC}"
    fi
done

# server.properties
if [ ! -f "$MC_DIR/server.properties" ] && [ -f "$SCRIPT_DIR/server.properties" ]; then
    sudo cp "$SCRIPT_DIR/server.properties" "$MC_DIR/"
    echo -e "${GREEN}  server.properties configurado.${NC}"
fi

# start.sh
sudo cp "$SCRIPT_DIR/start.sh" "$MC_DIR/"
sudo chmod +x "$MC_DIR/start.sh"
sudo chown $MINECRAFT_USER:$MINECRAFT_USER "$MC_DIR/start.sh"

# eula.txt
if [ ! -f "$MC_DIR/eula.txt" ]; then
    echo "eula=true" | sudo tee "$MC_DIR/eula.txt" > /dev/null
    sudo chown $MINECRAFT_USER:$MINECRAFT_USER "$MC_DIR/eula.txt"
    echo -e "${GREEN}  eula.txt aceito.${NC}"
fi

# playit agente
if [ -f "$SCRIPT_DIR/playit" ]; then
    sudo cp "$SCRIPT_DIR/playit" "$MC_DIR/"
    sudo chmod +x "$MC_DIR/playit"
    sudo chown $MINECRAFT_USER:$MINECRAFT_USER "$MC_DIR/playit"
    echo -e "${GREEN}  Playit.gg agente copiado.${NC}"
fi

sudo chown -R $MINECRAFT_USER:$MINECRAFT_USER "$MC_DIR/"

echo ""
echo -e "${YELLOW}[5/5] Instalando servico systemd...${NC}"
sudo cp "$SCRIPT_DIR/minecraft.service" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable minecraft.service
echo -e "${GREEN}  Servico habilitado.${NC}"

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${GREEN}  INSTALACAO CONCLUIDA!${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
echo -e "  Iniciar:    ${YELLOW}sudo systemctl start minecraft${NC}"
echo -e "  Parar:      ${YELLOW}sudo systemctl stop minecraft${NC}"
echo -e "  Logs:       ${YELLOW}sudo journalctl -u minecraft -f${NC}"
echo -e "  Console:    ${YELLOW}sudo systemctl stop minecraft && cd $MC_DIR && sudo -u $MINECRAFT_USER bash start.sh${NC}"
echo ""
echo -e "  ${RED}IMPORTANTE: No console use /op <seu-nick> para vir admin!${NC}"
echo ""
