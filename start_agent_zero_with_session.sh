#!/bin/bash

# Skript zum Starten von Agent Zero in Docker mit den Inhalten der letzten Sitzung

echo "Erstelle Docker-Container für Agent Zero mit vorherigen Sitzungsdaten..."

# Erstelle einen Docker-Container mit Volume-Mapping für die Sitzungsdaten und Port-Zuweisung
docker run -d \
  --name agent-zero-session \
  -p 80:80 \
  -p 9000-9009:9000-9009 \
  -p 22:22 \
  -v "$(pwd)/agent-zero-data:/a0/agent-zero-data" \
  -v "$(pwd):/git/agent-zero" \
  -e BRANCH=local \
  agent0ai/agent-zero-base:latest \
  bash -c "cd /git/agent-zero && /usr/bin/python3 prepare.py --dockerized=true && /usr/bin/python3 run_ui.py --dockerized=true --port=80 --host=0.0.0.0"

echo "Agent Zero Container wurde gestartet mit Zugriff auf vorherige Sitzungsdaten."
echo "Der Container ist unter dem Namen 'agent-zero-session' verfügbar."
echo "Zugriff auf die Web-Oberfläche unter http://localhost:80"