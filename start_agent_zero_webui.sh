#!/bin/bash

# Entferne alte Container, falls vorhanden
docker stop agent-zero-webui 2>/dev/null
docker rm agent-zero-webui 2>/dev/null

echo "Erstelle und starte Agent Zero mit WebUI..."

# Starte Agent Zero Container mit korrektem Setup
docker run -d \
  --name agent-zero-webui \
  -p 50080:80 \
  -v "$(pwd)/agent-zero-data:/a0/agent-zero-data" \
  -v "$(pwd):/git/agent-zero" \
  agent0ai/agent-zero-base:latest \
  bash -c "
    # Installiere Agent Zero im Container
    cd /git/agent-zero &&
    bash /ins/pre_install.sh local &&
    bash /ins/install_A0.sh local &&
    bash /ins/install_additional.sh local &&
    bash /ins/install_A02.sh local &&
    bash /ins/post_install.sh local &&
    # Bereite Agent Zero vor
    python3 /git/agent-zero/prepare.py --dockerized=true &&
    # Starte die WebUI
    python3 /git/agent-zero/run_ui.py --dockerized=true --port=80 --host=0.0.0.0
  "

echo "Agent Zero wird gestartet..."
echo "Warten Sie etwa 30 Sekunden, bis der Dienst vollständig geladen ist."
echo "Greifen Sie dann auf die Web-Oberfläche zu unter: http://localhost:50080"