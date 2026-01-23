# Agent Zero Projektübersicht

## Projektbeschreibung
Agent Zero ist ein persönliches, organisch wachsendes agentic Framework, das mit Ihnen lernt und wächst. Es handelt sich um einen allgemeinen Assistenten, der nicht für spezifische Aufgaben vorprogrammiert ist, sondern dynamisch und anpassungsfähig arbeitet. Das Framework ist vollständig transparent, lesbar, verständlich, anpassbar und interaktiv.

## Hauptmerkmale
1. **Allgemeiner Assistent**: Agent Zero ist nicht für spezifische Aufgaben vorprogrammiert, sondern kann Informationen sammeln, Befehle ausführen, mit anderen Agenten zusammenarbeiten und seine eigenen Tools erstellen.
2. **Computer als Werkzeug**: Der Agent nutzt das Betriebssystem als Werkzeug, um Aufgaben zu erledigen. Er kann eigenen Code schreiben und die Konsole verwenden, um seine eigenen Tools zu erstellen und zu benutzen.
3. **Multi-Agenten-Zusammenarbeit**: Jeder Agent hat einen übergeordneten Agenten und kann untergeordnete Agenten erstellen, um Teilaufgaben zu lösen.
4. **Vollständig anpassbar und erweiterbar**: Fast nichts im Framework ist hart kodiert. Das gesamte Verhalten wird durch Prompts definiert, insbesondere durch die Datei `prompts/default/agent.system.md`.
5. **Kommunikation ist entscheidend**: Agenten kommunizieren mit ihren über- und untergeordneten Agenten, stellen Fragen und geben Anweisungen.

## Architektur
- **Agent-Kern** (`agent.py`): Hauptklasse für Agenten mit Konfiguration, Historie und Kommunikationsfunktionen
- **Modellkonfiguration** (`models.py`): Verwaltung von Sprachmodellen (Chat, Utility, Embedding) mit Rate Limiting und verschiedenen Anbietern
- **Web-UI** (`run_ui.py`): Flask-basierte Benutzeroberfläche für die Interaktion mit Agenten
- **Initialisierung** (`initialize.py`): Startet Agentenkontexte, MCP-Server und Job-Schleifen
- **Konfiguration** (`python/helpers/settings.py`): Verwaltung der Einstellungen und deren Darstellung in der Benutzeroberfläche

## Technologien
- Python 3.x
- Flask für die Web-Oberfläche
- LangChain für Sprachmodellintegration
- LiteLLM für Anbieterunabhängigkeit
- Docker für Containerisierung
- Playwright für Browser-Automatisierung
- FAISS für Vektorspeicher

## Dateistruktur
- `agents/` - Spezifische Agentenprofile und deren Konfigurationen
- `prompts/` - Prompt-Vorlagen für verschiedene Agentenrollen
- `python/` - Hauptquellcode des Frameworks
- `webui/` - Frontend-Dateien für die Web-Oberfläche
- `docker/` - Docker-Konfigurationsdateien
- `tmp/` - Temporäre Dateien und Chat-Verläufe
- `memory/` - Gespeicherte Erinnerungen und Lösungen
- `knowledge/` - Wissensbasis für den Agenten
- `instruments/` - Wiederverwendbare Funktionen und Prozeduren

## Building und Ausführen

### Lokale Ausführung
```bash
# Voraussetzungen installieren
pip install -r requirements.txt

# Agent Zero starten
python run_ui.py
```

### Docker-Ausführung
```bash
# Schnellstart mit Docker
docker pull agent0ai/agent-zero
docker run -p 50001:80 agent0ai/agent-zero

# Besuch unter http://localhost:50001
```

### Entwicklung mit Docker
```bash
# Mit lokalen Dateien und Sitzungsdaten
docker run -d \
  --name agent-zero-dev \
  -p 50080:80 \
  -v "$(pwd)/agent-zero-data:/a0/agent-zero-data" \
  -v "$(pwd):/git/agent-zero" \
  agent0ai/agent-zero:latest
```

## Entwicklungskonventionen
- Das gesamte Verhalten wird durch Prompts gesteuert, hauptsächlich in `prompts/`-Ordner
- Neue Tools können in `python/tools/` erstellt werden
- Instrumente sind wiederverwendbare Funktionen, die vom Agenten aufgerufen werden können
- Die Kommunikation zwischen Agenten erfolgt über JSON-Nachrichten mit festgelegtem Format
- Für die Entwicklung sollten Änderungen am Verhalten über die Prompt-Dateien erfolgen, nicht durch Änderung des Kerncodes

## Hauptkomponenten
- **AgentContext**: Verwaltet den Kontext für jede Agenten-Sitzung
- **AgentConfig**: Enthält die Konfiguration für Sprachmodelle und andere Einstellungen
- **LiteLLMChatWrapper**: Wrapper für die Sprachmodellkommunikation mit Rate Limiting und Streaming
- **WebApp**: Flask-Anwendung für die Web-Oberfläche mit Authentifizierung
- **API Handler**: REST-API-Endpunkte für externe Kommunikation

## Besonderheiten
- Unterstützung für mehrere Sprachmodellanbieter (OpenAI, Anthropic, Google, etc.)
- Integriertes Memory-System zur Speicherung von Lösungen und Informationen
- Rate Limiting für API-Aufrufe
- Streaming-Unterstützung für Echtzeit-Ausgabe
- Unterstützung für visuelle Modelle (Vision)
- Browser-Automatisierung mit browser-use
- MCP (Model Context Protocol) Unterstützung
- A2A (Agent to Agent) Kommunikationsprotokoll