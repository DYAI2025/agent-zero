# Agent Zero - Schnellstart-Anleitung

## 🎯 Ihr Agent Zero System ist bereit!

### Zugriff auf die Web-UI
**http://localhost:50080**

---

## ⚡ Schnellbefehle

### Container-Verwaltung
```bash
# Container Status
docker ps | grep agent-zero

# Container stoppen
docker stop agent-zero-main

# Container starten
docker start agent-zero-main

# Container neu starten
docker restart agent-zero-main

# Logs anzeigen
docker logs -f agent-zero-main

# In Container einloggen
docker exec -it agent-zero-main bash
```

### Service-Verwaltung
```bash
# Alle Services anzeigen
docker exec agent-zero-main supervisorctl status

# Service neu starten
docker exec agent-zero-main supervisorctl restart run_ui

# Alle Services neu starten
docker exec agent-zero-main supervisorctl restart all
```

---

## 📁 Persistente Daten

```
./agent-zero-data/
├── memory/      - Agent-Gedächtnis
├── knowledge/   - Wissensdatenbank
├── logs/        - System-Logs
└── tmp/         - Einstellungen & Temp-Dateien
```

---

## 🔑 Erste Schritte

1. **Web-UI öffnen**: http://localhost:50080
2. **Einstellungen öffnen**: Klick auf ⚙️ Icon
3. **API-Key hinzufügen**:
   - OpenAI: Für GPT-Modelle
   - Anthropic: Für Claude-Modelle
   - OpenRouter: Für verschiedene Modelle
4. **Modell wählen**: Empfohlen: GPT-4o oder Claude Sonnet
5. **Los geht's**: Stellen Sie Ihre erste Frage!

---

## 💡 Beispiel-Prompts

### Entwicklung
```
"Erstelle eine Python-Funktion zum Sortieren einer Liste"
"Analysiere diese Datei und finde Bugs"
```

### Datenanalyse
```
"Analysiere die CSV-Datei und erstelle einen Report"
"Zeige mir Trends in den Daten"
```

### Recherche
```
"Finde die neuesten Informationen über [Thema]"
"Vergleiche [Option A] mit [Option B]"
```

### Systemadministration
```
"Prüfe den Systemstatus"
"Erstelle ein Backup-Script"
```

---

## 🛠️ Verfügbare Tools

- ✅ **Code-Ausführung** (Python, Bash, Node.js)
- ✅ **Web-Suche** (SearXNG integriert)
- ✅ **Datei-Operationen**
- ✅ **Browser-Automation**
- ✅ **PDF/Dokument-Verarbeitung**
- ✅ **Multi-Agent-Koordination**

---

## 🔧 Wichtige Ports

| Port | Service | Zugriff |
|------|---------|---------|
| 50080 | Web UI | http://localhost:50080 |
| 22 | SSH (im Container) | Nicht extern gemappt |

---

## 📊 System-Informationen

### Container-Details
```bash
# Image-Version
docker inspect agent-zero-main | grep Image

# Container-Uptime
docker ps --filter name=agent-zero-main

# Ressourcen-Nutzung
docker stats agent-zero-main
```

---

## ⚠️ Wichtige Hinweise

1. **API-Keys**: Niemals in Git committen!
2. **Ressourcen**: Agent Zero benötigt mind. 2GB RAM
3. **Rate-Limits**: Beachten Sie API-Provider Limits
4. **Backups**: Sichern Sie `agent-zero-data/` regelmäßig

---

## 🆘 Hilfe & Support

### Dokumentation
- 📖 [Vollständige Anleitung](./DOCKER_INSTALLATION_DE.md)
- 🌐 [Offizielle Docs](https://agent-zero.ai)
- 📺 [YouTube Tutorials](https://www.youtube.com/@AgentZeroFW)

### Community
- 💬 [Discord](https://discord.gg/B8KZKNsPpj)
- 🐙 [GitHub](https://github.com/agent0ai/agent-zero)
- 🎓 [Skool Community](https://www.skool.com/agent-zero)

---

## 🚀 Erweiterte Features

### Projekte erstellen
- Isolierte Workspaces
- Projekt-spezifische Prompts
- Dedizierte Dateien & Secrets

### Subordinate Agents
- Erstellen Sie spezialisierte Unter-Agenten
- Hierarchische Aufgabenverwaltung
- Kollaborative Problemlösung

### Memory-System
- Persistentes Gedächtnis
- Automatische Embedding-Erstellung
- Kontext-basiertes Abrufen

---

**Viel Erfolg! 🎉**

Bei Fragen: [Discord Community](https://discord.gg/B8KZKNsPpj)
