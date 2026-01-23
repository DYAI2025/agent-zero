# Agent Zero - Docker Installation (Deutsch)

## 🎉 Installation erfolgreich abgeschlossen!

Agent Zero wurde erfolgreich als vollständiges Agentensystem in Docker installiert.

## 📋 Installierte Komponenten

### Container-Details
- **Container Name**: `agent-zero-main`
- **Image**: `agent0ai/agent-zero:latest`
- **Port**: 50080 (Host) → 80 (Container)
- **Status**: ✅ Läuft

### Aktive Dienste
Alle folgenden Dienste laufen im Container:

1. **run_ui** - Web-Benutzeroberfläche (Port 80/50080)
2. **run_searxng** - Integrierte Suchmaschine
3. **run_sshd** - SSH-Daemon für Remote-Zugriff
4. **run_tunnel_api** - Tunnel-API für externe Verbindungen
5. **run_cron** - Geplante Aufgaben
6. **the_listener** - Event-Listener

### Persistente Daten
Die folgenden Verzeichnisse sind auf Ihrem Host-System gemappt:

```
./agent-zero-data/
├── memory/      → /a0/memory    (Agent-Gedächtnis)
├── knowledge/   → /a0/knowledge (Wissensdatenbank)
├── logs/        → /a0/logs      (Protokolle)
└── tmp/         → /a0/tmp       (Temporäre Dateien)
```

## 🚀 Zugriff auf Agent Zero

### Web-Interface
Öffnen Sie Ihren Browser und navigieren Sie zu:

**http://localhost:50080**

### Erste Schritte
1. Konfigurieren Sie Ihre API-Schlüssel in den Einstellungen
2. Wählen Sie Ihr bevorzugtes LLM-Modell
3. Starten Sie Ihr erstes Gespräch mit dem Agenten

## 🛠️ Container-Verwaltung

### Container stoppen
```bash
docker stop agent-zero-main
```

### Container starten
```bash
docker start agent-zero-main
```

### Container neustarten
```bash
docker restart agent-zero-main
```

### Container entfernen
```bash
docker stop agent-zero-main
docker rm agent-zero-main
```

### Logs anzeigen
```bash
# Alle Logs
docker logs agent-zero-main

# Letzte 50 Zeilen
docker logs agent-zero-main --tail 50

# Live-Logs verfolgen
docker logs -f agent-zero-main
```

### In Container einloggen
```bash
docker exec -it agent-zero-main bash
```

## 📊 Service-Status prüfen

```bash
docker exec agent-zero-main supervisorctl status
```

## 🔧 Konfiguration

### API-Schlüssel hinzufügen
1. Öffnen Sie die Web-UI unter http://localhost:50080
2. Klicken Sie auf das Einstellungen-Symbol
3. Fügen Sie Ihre API-Schlüssel hinzu:
   - OpenAI API Key
   - Anthropic API Key
   - Weitere Anbieter nach Bedarf

### Einstellungen persistieren
Die Einstellungen werden in `/a0/tmp/settings.json` gespeichert und bleiben erhalten.

## 🎯 Features

### Multi-Agent-System
- Hauptagent (Agent 0) kann Unteragenten erstellen
- Hierarchische Aufgabenverwaltung
- Kooperative Problemlösung

### Verfügbare Tools
- **Code-Ausführung**: Python, Bash, Node.js
- **Web-Suche**: Integrierte SearXNG-Suchmaschine
- **Datei-Operationen**: Lesen, Schreiben, Bearbeiten
- **Browser-Automation**: Mit browser-use
- **Dokument-Verarbeitung**: PDF, Markdown, etc.
- **Memory-System**: Persistentes Gedächtnis

### Projekt-Management
- Isolierte Workspaces
- Projektspezifische Prompts
- Dedizierte Dateien und Geheimnisse

## 🔐 Sicherheit

### Wichtige Hinweise
- Agent Zero läuft in einer isolierten Docker-Umgebung
- Der Agent kann Code ausführen - verwenden Sie ihn verantwortungsvoll
- Speichern Sie keine sensiblen Daten im Repository
- Verwenden Sie die Secrets-Verwaltung für Anmeldedaten

### SSH-Zugriff (optional)
Der Container läuft mit SSH-Daemon. Bei Bedarf können Sie sich einloggen:

```bash
# Standard SSH-Port ist im Container auf 22
# Sie müssen den Port in der docker run Konfiguration mappen
```

## 🆙 Updates

### Neueste Version pullen
```bash
docker pull agent0ai/agent-zero:latest
```

### Container mit neuer Version neu erstellen
```bash
# Alten Container stoppen und entfernen
docker stop agent-zero-main
docker rm agent-zero-main

# Neuen Container mit aktualisiertem Image starten
docker run -d --name agent-zero-main \
  -p 50080:80 \
  -v "$(pwd)/agent-zero-data/memory:/a0/memory" \
  -v "$(pwd)/agent-zero-data/knowledge:/a0/knowledge" \
  -v "$(pwd)/agent-zero-data/logs:/a0/logs" \
  -v "$(pwd)/agent-zero-data/tmp:/a0/tmp" \
  agent0ai/agent-zero:latest
```

## 📚 Weitere Ressourcen

### Dokumentation
- [Offizielle Dokumentation](https://agent-zero.ai)
- [GitHub Repository](https://github.com/agent0ai/agent-zero)
- [Discord Community](https://discord.gg/B8KZKNsPpj)
- [YouTube Kanal](https://www.youtube.com/@AgentZeroFW)

### Erweiterte Features
- [Entwicklerdokumentation](./development.md)
- [Erweiterbarkeit](./extensibility.md)
- [Konnektivität](./connectivity.md)
- [Architektur](./architecture.md)

## 🎓 Beispiele

### Entwicklungsaufgaben
```
"Erstelle ein React-Dashboard mit Echtzeit-Datenvisualisierung"
```

### Datenanalyse
```
"Analysiere die Verkaufsdaten des letzten Quartals und erstelle Trendberichte"
```

### Content-Erstellung
```
"Schreibe einen technischen Blog-Post über Microservices"
```

### Systemadministration
```
"Richte ein Monitoring-System für unsere Webserver ein"
```

### Forschung
```
"Sammle und fasse fünf aktuelle KI-Paper über Chain-of-Thought Prompting zusammen"
```

## 🐛 Fehlersuche

### Container startet nicht
```bash
# Prüfen Sie die Logs
docker logs agent-zero-main

# Prüfen Sie, ob der Port bereits verwendet wird
lsof -i :50080

# Prüfen Sie die Docker-Logs
docker events
```

### Web-UI nicht erreichbar
1. Prüfen Sie, ob der Container läuft: `docker ps | grep agent-zero`
2. Prüfen Sie die Service-Status: `docker exec agent-zero-main supervisorctl status`
3. Prüfen Sie die UI-Logs: `docker logs agent-zero-main | grep run_ui`

### Dienste neu starten
```bash
# Einzelnen Dienst neu starten
docker exec agent-zero-main supervisorctl restart run_ui

# Alle Dienste neu starten
docker exec agent-zero-main supervisorctl restart all
```

## 💡 Tipps

1. **Backup**: Sichern Sie regelmäßig das `agent-zero-data` Verzeichnis
2. **Ressourcen**: Agent Zero kann ressourcenintensiv sein - stellen Sie ausreichend RAM bereit
3. **API-Limits**: Beachten Sie die Rate-Limits Ihrer API-Anbieter
4. **Logging**: Aktivieren Sie Logging für bessere Fehlersuche

## ✅ Installation Status

- ✅ Docker installiert und läuft
- ✅ Agent Zero Image heruntergeladen
- ✅ Datenverzeichnisse erstellt
- ✅ Container gestartet und läuft
- ✅ Alle Dienste aktiv
- ✅ Web-UI verfügbar unter http://localhost:50080

---

**Viel Erfolg mit Agent Zero! 🚀**

Bei Fragen oder Problemen besuchen Sie:
- [Discord Community](https://discord.gg/B8KZKNsPpj)
- [GitHub Issues](https://github.com/agent0ai/agent-zero/issues)
