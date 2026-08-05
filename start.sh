#!/bin/bash
# ============================================================
#  SCRIPT DE INICIALIZACAO - SERVIDOR MINECRAFT PAPERMC
#  Aikar's Flags otimizadas para Java 25 + hardware limitado
# ============================================================

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

# ============================================================
#  DETECAO AUTOMATICA DE RAM
#  Usa 60% da RAM total (minimo 1024MB, maximo 4096MB)
# ============================================================

TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))
RECOMMENDED_RAM=$((TOTAL_RAM_MB * 60 / 100))

if [ "$RECOMMENDED_RAM" -lt 1024 ]; then
    RECOMMENDED_RAM=1024
elif [ "$RECOMMENDED_RAM" -gt 4096 ]; then
    RECOMMENDED_RAM=4096
fi

echo "RAM Total do Sistema: ${TOTAL_RAM_MB}MB"
echo "RAM Alocada para o Servidor: ${RECOMMENDED_RAM}MB"

# ============================================================
#  AIKAR'S FLAGS - Java 25 + G1GC
# ============================================================

java \
    -Xms${RECOMMENDED_RAM}M \
    -Xmx${RECOMMENDED_RAM}M \
    -XX:+UseG1GC \
    -XX:+ParallelRefProcEnabled \
    -XX:MaxGCPauseMillis=200 \
    -XX:+UnlockExperimentalVMOptions \
    -XX:+DisableExplicitGC \
    -XX:+AlwaysPreTouch \
    -XX:G1NewSizePercent=30 \
    -XX:G1MaxNewSizePercent=40 \
    -XX:G1HeapRegionSize=8M \
    -XX:G1ReservePercent=20 \
    -XX:G1HeapWastePercent=5 \
    -XX:G1MixedGCCountTarget=4 \
    -XX:InitiatingHeapOccupancyPercent=15 \
    -XX:G1MixedGCLiveThresholdPercent=90 \
    -XX:G1RSetUpdatingPauseTimePercent=5 \
    -XX:SurvivorRatio=32 \
    -XX:+PerfDisableSharedMem \
    -XX:MaxTenuringThreshold=1 \
    -Dusing.aikars.flags=https://mcflags.emc.gs \
    -Daikars.new.flags=true \
    -jar paper.jar \
    --nogui || true

# ============================================================
#  REINICIO AUTOMATICO EM CASO DE CRASH
# ============================================================

echo ""
echo "============================================"
echo "  SERVIDOR ENCERROU!"
echo "  Reiniciando em 10 segundos..."
echo "  Pressione Ctrl+C para cancelar."
echo "============================================"
sleep 10
exec "$0"
