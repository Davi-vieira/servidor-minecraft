#!/bin/bash
# ============================================================
#  DOWNLOAD AUTOMATIZADO - PAPERMC + PLUGINS
#  URLs diretas e confiáveis
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SERVER_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGINS_DIR="$SERVER_DIR/plugins"

echo -e "${YELLOW}Diretorio do servidor: $SERVER_DIR${NC}"

mkdir -p "$PLUGINS_DIR"

# ============================================================
#  FUNCAO DE DOWNLOAD COM RETRY
# ============================================================
download_file() {
    local url="$1"
    local dest="$2"
    local desc="$3"
    echo -e "${YELLOW}[${desc}] Baixando...${NC}"
    if wget -q --show-progress --timeout=30 --tries=3 -O "$dest" "$url"; then
        local size
        size=$(stat -c%s "$dest" 2>/dev/null || echo 0)
        if [ "$size" -gt 10000 ]; then
            echo -e "${GREEN}[${desc}] OK ($(( size / 1024 ))KB)${NC}"
            return 0
        fi
    fi
    rm -f "$dest"
    echo -e "${RED}[${desc}] FALHOU${NC}"
    return 1
}

# ============================================================
#  1. PAPERMC - API v2 direta
# ============================================================
echo ""
echo -e "${YELLOW}[PaperMC] Buscando versao...${NC}"

EXISTING_JAR=$(find "$SERVER_DIR" -maxdepth 1 -name "paper-*.jar" -size +1M 2>/dev/null | head -1)
if [ -n "$EXISTING_JAR" ]; then
    echo -e "${GREEN}[PaperMC] $(basename "$EXISTING_JAR") ja existe. Pulando.${NC}"
    JAR_NAME=$(basename "$EXISTING_JAR")
else
    # Usar API v2 diretamente (v3 retorna versoes invalidas)
    LATEST_VERSION=$(curl -sf "https://api.papermc.io/v2/projects/paper" | jq -r '.versions[-1]' 2>/dev/null || echo "")

    if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" = "null" ]; then
        LATEST_VERSION="1.21.4"
        echo -e "${YELLOW}[PaperMC] API indisponivel, usando 1.21.4${NC}"
    else
        echo -e "${YELLOW}[PaperMC] Versao: $LATEST_VERSION${NC}"
    fi

    LATEST_BUILD=$(curl -sf "https://api.papermc.io/v2/projects/paper/versions/${LATEST_VERSION}" | jq -r '.builds[-1]' 2>/dev/null || echo "")

    if [ -z "$LATEST_BUILD" ] || [ "$LATEST_BUILD" = "null" ]; then
        LATEST_BUILD="150"
        LATEST_VERSION="1.21.4"
        echo -e "${YELLOW}[PaperMC] Usando build fixo 1.21.4-150${NC}"
    fi

    JAR_NAME="paper-${LATEST_VERSION}.jar"
    PAPER_URL="https://api.papermc.io/v2/projects/paper/versions/${LATEST_VERSION}/builds/${LATEST_BUILD}/downloads/paper-${LATEST_VERSION}-${LATEST_BUILD}.jar"

    download_file "$PAPER_URL" "$SERVER_DIR/$JAR_NAME" "PaperMC" || {
        echo -e "${RED}[PaperMC] Baixe manualmente: https://papermc.io/downloads/paper${NC}"
    }
fi

if [ -f "$SERVER_DIR/$JAR_NAME" ]; then
    rm -f "$SERVER_DIR/paper.jar"
    ln -sf "$JAR_NAME" "$SERVER_DIR/paper.jar"
    echo -e "${GREEN}[PaperMC] Symlink paper.jar criado.${NC}"
fi

# ============================================================
#  2. GEYSERMC - GitHub releases direto
# ============================================================
echo ""
GEYSER_JAR="$PLUGINS_DIR/Geyser-Spigot.jar"
if [ -f "$GEYSER_JAR" ] && [ "$(stat -c%s "$GEYSER_JAR" 2>/dev/null || echo 0)" -gt 100000 ]; then
    echo -e "${GREEN}[GeyserMC] Ja existe. Pulando.${NC}"
else
    GEYSER_URL=$(curl -sf "https://api.github.com/repos/GeyserMC/Geyser/releases/latest" \
        | jq -r '.assets[] | select(.name | test("Geyser-Spigot")) | .browser_download_url' 2>/dev/null | head -1)

    if [ -n "$GEYSER_URL" ] && [ "$GEYSER_URL" != "null" ]; then
        download_file "$GEYSER_URL" "$GEYSER_JAR" "GeyserMC" || \
            echo -e "${RED}[GeyserMC] Baixe em: https://geysermc.org/download${NC}"
    else
        # URL direta do build mais recente conhecido
        download_file "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot" \
            "$GEYSER_JAR" "GeyserMC" || \
            echo -e "${RED}[GeyserMC] Baixe em: https://geysermc.org/download${NC}"
    fi
fi

# ============================================================
#  3. FLOODGATE - GitHub releases direto
# ============================================================
echo ""
FLOODGATE_JAR="$PLUGINS_DIR/floodgate-spigot.jar"
if [ -f "$FLOODGATE_JAR" ] && [ "$(stat -c%s "$FLOODGATE_JAR" 2>/dev/null || echo 0)" -gt 10000 ]; then
    echo -e "${GREEN}[Floodgate] Ja existe. Pulando.${NC}"
else
    FLOODGATE_URL=$(curl -sf "https://api.github.com/repos/GeyserMC/Floodgate/releases/latest" \
        | jq -r '.assets[] | select(.name | test("floodgate-spigot")) | .browser_download_url' 2>/dev/null | head -1)

    if [ -n "$FLOODGATE_URL" ] && [ "$FLOODGATE_URL" != "null" ]; then
        download_file "$FLOODGATE_URL" "$FLOODGATE_JAR" "Floodgate" || \
            echo -e "${RED}[Floodgate] Baixe em: https://geysermc.org/download${NC}"
    else
        download_file "https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot" \
            "$FLOODGATE_JAR" "Floodgate" || \
            echo -e "${RED}[Floodgate] Baixe em: https://geysermc.org/download${NC}"
    fi
fi

# ============================================================
#  4. AUTHME - GitHub releases direto
# ============================================================
echo ""
AUTHME_JAR="$PLUGINS_DIR/AuthMe.jar"
if [ -f "$AUTHME_JAR" ] && [ "$(stat -c%s "$AUTHME_JAR" 2>/dev/null || echo 0)" -gt 10000 ]; then
    echo -e "${GREEN}[AuthMe] Ja existe. Pulando.${NC}"
else
    AUTHME_URL=$(curl -sf "https://api.github.com/repos/AuthMe-Team/AuthMeReloaded/releases/latest" \
        | jq -r '.assets[] | select(.name | test("AuthMe")) | .browser_download_url' 2>/dev/null | head -1)

    if [ -n "$AUTHME_URL" ] && [ "$AUTHME_URL" != "null" ]; then
        download_file "$AUTHME_URL" "$AUTHME_JAR" "AuthMe" || \
            echo -e "${RED}[AuthMe] Baixe em: https://github.com/AuthMe-Team/AuthMeReloaded/releases${NC}"
    else
        download_file "https://github.com/AuthMe-Team/AuthMeReloaded/releases/latest/download/AuthMe.jar" \
            "$AUTHME_JAR" "AuthMe" || \
            echo -e "${RED}[AuthMe] Baixe em: https://github.com/AuthMe-Team/AuthMeReloaded/releases${NC}"
    fi
fi

# ============================================================
#  5. PLAYIT.GG PLUGIN
# ============================================================
echo ""
PLAYIT_JAR="$PLUGINS_DIR/playit-plugin.jar"
if [ -f "$PLAYIT_JAR" ] && [ "$(stat -c%s "$PLAYIT_JAR" 2>/dev/null || echo 0)" -gt 10000 ]; then
    echo -e "${GREEN}[Playit.gg] Ja existe. Pulando.${NC}"
else
    PLAYIT_URL=$(curl -sf "https://api.github.com/repos/playit-cloud/playit-minecraft-plugin/releases/latest" \
        | jq -r '.assets[] | select(.name | test("\\.jar$")) | .browser_download_url' 2>/dev/null | head -1)

    if [ -n "$PLAYIT_URL" ] && [ "$PLAYIT_URL" != "null" ]; then
        download_file "$PLAYIT_URL" "$PLAYIT_JAR" "Playit.gg" || \
            echo -e "${RED}[Playit.gg] Baixe em: https://playit.gg/download/bukkit${NC}"
    else
        download_file "https://github.com/playit-cloud/playit-minecraft-plugin/releases/latest/download/playit-minecraft-plugin.jar" \
            "$PLAYIT_JAR" "Playit.gg" || \
            echo -e "${RED}[Playit.gg] Baixe em: https://playit.gg/download/bukkit${NC}"
    fi
fi

# ============================================================
#  RESUMO
# ============================================================
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  RESULTADO DOS DOWNLOADS${NC}"
echo -e "${GREEN}========================================${NC}"

check_file() {
    local file="$1" label="$2" minsize="$3"
    local size
    size=$(stat -c%s "$file" 2>/dev/null || echo 0)
    if [ "$size" -gt "$minsize" ]; then
        echo -e "  ${GREEN}OK${NC}  $label ($(( size / 1024 ))KB)"
    else
        echo -e "  ${RED}FALHOU${NC}  $label"
    fi
}

PAPER_FOUND=$(find "$SERVER_DIR" -maxdepth 1 -name "paper-*.jar" -size +1M 2>/dev/null | head -1)
[ -n "$PAPER_FOUND" ] && echo -e "  ${GREEN}OK${NC}  PaperMC: $(basename "$PAPER_FOUND")" || echo -e "  ${RED}FALHOU${NC}  PaperMC"

check_file "$PLUGINS_DIR/Geyser-Spigot.jar"    "Geyser-Spigot.jar"    100000
check_file "$PLUGINS_DIR/floodgate-spigot.jar" "floodgate-spigot.jar" 10000
check_file "$PLUGINS_DIR/AuthMe.jar"           "AuthMe.jar"           10000
check_file "$PLUGINS_DIR/playit-plugin.jar"    "playit-plugin.jar"    10000
check_file "$PLUGINS_DIR/GriefPrevention.jar"  "GriefPrevention.jar"  10000
check_file "$PLUGINS_DIR/SetHome.jar"          "SetHome.jar"          10000

echo -e "${GREEN}========================================${NC}"
