# Agent Zero - API-Keys Konfiguration

## 🔑 API-Schlüssel hinzufügen

Es gibt drei Methoden, um API-Keys für Agent Zero zu konfigurieren.

---

## ✅ **Methode 1: Web-UI (EMPFOHLEN)**

Die einfachste und sicherste Methode:

### Schritte:
1. Öffnen Sie **http://localhost:50080**
2. Klicken Sie auf das **⚙️ Einstellungen-Symbol** (oben rechts)
3. Wählen Sie **"Models"** im Menü
4. Fügen Sie Ihre API-Keys hinzu:

#### Unterstützte Anbieter:
- **OpenAI**: Für GPT-Modelle (GPT-4, GPT-4o, etc.)
- **Anthropic**: Für Claude-Modelle (Claude Opus, Sonnet, Haiku)
- **OpenRouter**: Zugang zu verschiedenen Modellen
- **Google**: Für Gemini-Modelle
- **Azure OpenAI**: Für Azure-gehostete Modelle
- **Groq**: Für schnelle Inferenz
- **Ollama**: Für lokale Modelle

5. Klicken Sie **"Save Settings"**

### Vorteile:
- ✅ Benutzerfreundlich
- ✅ Validierung in Echtzeit
- ✅ Sichere Speicherung
- ✅ Automatisch persistiert
- ✅ Keine Neustart erforderlich

---

## 📝 **Methode 2: .env Datei bearbeiten (Manuell)**

Die .env Datei liegt jetzt in: `./agent-zero-data/.env`

### Schritte:

#### 1. Bearbeiten Sie die Datei:
```bash
# Mit Ihrem bevorzugten Editor
nano ./agent-zero-data/.env
# oder
code ./agent-zero-data/.env
```

#### 2. Fügen Sie Ihre API-Keys hinzu:
```bash
# OpenAI API Key
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Anthropic API Key (für Claude)
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# OpenRouter API Key
OPENROUTER_API_KEY=sk-or-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Google API Key (für Gemini)
GOOGLE_API_KEY=AIzaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Groq API Key
GROQ_API_KEY=gsk_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Azure OpenAI (optional)
AZURE_OPENAI_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_API_VERSION=2024-02-15-preview

# Ollama (für lokale Modelle, optional)
OLLAMA_BASE_URL=http://host.docker.internal:11434
```

#### 3. Kopieren Sie die Datei zurück in den Container:
```bash
docker cp ./agent-zero-data/.env agent-zero-main:/a0/.env
```

#### 4. Container neu starten:
```bash
docker restart agent-zero-main
```

### Beispiel einer vollständigen .env Datei:
```bash
# === Runtime Konfiguration (automatisch generiert) ===
A0_PERSISTENT_RUNTIME_ID=c13febd01bf518de389462d4d48b2285
ROOT_PASSWORD=v5zJUMZing5353FJSO0GRhwdULcD9dYU
DEFAULT_USER_UTC_OFFSET_MINUTES=60
DEFAULT_USER_TIMEZONE=Europe/Berlin

# === API-Schlüssel (von Ihnen hinzugefügt) ===

# OpenAI (erforderlich für GPT-Modelle)
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Anthropic (erforderlich für Claude-Modelle)
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# OpenRouter (optional, aber empfohlen für Modellvielfalt)
OPENROUTER_API_KEY=sk-or-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Google Gemini (optional)
GOOGLE_API_KEY=AIzaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Groq (optional, für schnelle Inferenz)
GROQ_API_KEY=gsk_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# === Weitere Optionen ===

# Debug-Modus
DEBUG=false

# Logging-Level
LOG_LEVEL=INFO
```

---

## 🐳 **Methode 3: .env Datei direkt im Container bearbeiten**

Für Fortgeschrittene - Bearbeitung direkt im Container:

```bash
# In Container einloggen
docker exec -it agent-zero-main bash

# .env bearbeiten (mit vi oder nano)
nano /a0/.env

# Datei speichern und Container verlassen
exit

# Container neu starten
docker restart agent-zero-main
```

---

## 🔐 **API-Keys erhalten**

### OpenAI
1. Besuchen Sie: https://platform.openai.com/api-keys
2. Klicken Sie "Create new secret key"
3. Kopieren Sie den Key (beginnt mit `sk-proj-`)

### Anthropic (Claude)
1. Besuchen Sie: https://console.anthropic.com/settings/keys
2. Klicken Sie "Create Key"
3. Kopieren Sie den Key (beginnt mit `sk-ant-`)

### OpenRouter
1. Besuchen Sie: https://openrouter.ai/keys
2. Klicken Sie "Create Key"
3. Kopieren Sie den Key (beginnt mit `sk-or-`)

### Google (Gemini)
1. Besuchen Sie: https://makersuite.google.com/app/apikey
2. Klicken Sie "Create API Key"
3. Kopieren Sie den Key (beginnt mit `AIza`)

### Groq
1. Besuchen Sie: https://console.groq.com/keys
2. Klicken Sie "Create API Key"
3. Kopieren Sie den Key (beginnt mit `gsk_`)

---

## ⚙️ **Modell-Konfiguration**

Nach dem Hinzufügen der API-Keys müssen Sie ein Modell auswählen:

### In der Web-UI:
1. Gehen Sie zu **Settings** → **Models**
2. Wählen Sie Ihr bevorzugtes Modell:

#### Empfohlene Modelle:
| Modell | Anbieter | Stärken | Kosten |
|--------|----------|---------|--------|
| GPT-4o | OpenAI | Beste Balance | $$ |
| Claude 3.5 Sonnet | Anthropic | Coding, Analyse | $$ |
| Claude 3 Opus | Anthropic | Komplexe Aufgaben | $$$ |
| GPT-4 Turbo | OpenAI | Schnell & günstig | $ |
| Gemini Pro | Google | Multimodal | $ |

3. Klicken Sie **"Save Settings"**

---

## 🔍 **Konfiguration überprüfen**

### API-Keys testen:
```bash
# Container Logs anschauen
docker logs agent-zero-main | grep -i "api"

# Web-UI öffnen und Test-Prompt senden
# z.B.: "Hallo, kannst du mich hören?"
```

### Häufige Fehler:
1. **"Invalid API Key"**
   - Prüfen Sie, ob der Key korrekt kopiert wurde (keine Leerzeichen!)
   - Prüfen Sie, ob der Key noch gültig ist

2. **"API Key not found"**
   - Stellen Sie sicher, dass die .env Datei korrekt ist
   - Container neu starten: `docker restart agent-zero-main`

3. **"Rate limit exceeded"**
   - Sie haben das API-Limit erreicht
   - Wechseln Sie zu einem anderen Anbieter oder warten Sie

---

## 💡 **Tipps & Best Practices**

### Sicherheit:
- ✅ Speichern Sie API-Keys NIEMALS in Git
- ✅ Verwenden Sie Umgebungsvariablen
- ✅ Rotieren Sie Keys regelmäßig
- ✅ Setzen Sie Ausgabelimits bei den Anbietern

### Kosten-Optimierung:
- 💰 Starten Sie mit günstigen Modellen (GPT-4 Turbo, Gemini)
- 💰 Verwenden Sie OpenRouter für bessere Preise
- 💰 Setzen Sie monatliche Limits bei Ihrem Provider
- 💰 Nutzen Sie lokale Modelle (Ollama) für einfache Aufgaben

### Performance:
- ⚡ Groq für schnelle Antworten
- ⚡ Claude Sonnet für Code-Generation
- ⚡ GPT-4o für allgemeine Aufgaben

---

## 📊 **API-Nutzung überwachen**

### OpenAI:
https://platform.openai.com/usage

### Anthropic:
https://console.anthropic.com/settings/usage

### OpenRouter:
https://openrouter.ai/activity

---

## 🆘 **Probleme?**

### .env Datei wird nicht geladen
```bash
# Prüfen ob Datei existiert
docker exec agent-zero-main cat /a0/.env

# Datei-Berechtigungen prüfen
docker exec agent-zero-main ls -la /a0/.env

# Container-Logs anschauen
docker logs agent-zero-main | tail -50
```

### API-Key funktioniert nicht
```bash
# Testen Sie den Key direkt (OpenAI Beispiel)
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer YOUR_API_KEY"

# Oder für Anthropic
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: YOUR_API_KEY" \
  -H "anthropic-version: 2023-06-01"
```

---

## 📝 **Checkliste**

- [ ] Docker Container läuft
- [ ] .env Datei erstellt/bearbeitet
- [ ] API-Keys hinzugefügt
- [ ] .env zurück in Container kopiert (wenn Methode 2)
- [ ] Container neu gestartet
- [ ] Modell in Web-UI ausgewählt
- [ ] Test-Prompt gesendet
- [ ] Funktioniert! 🎉

---

## 🔗 **Weiterführende Links**

- [Agent Zero Dokumentation](https://agent-zero.ai)
- [OpenAI Pricing](https://openai.com/pricing)
- [Anthropic Pricing](https://www.anthropic.com/pricing)
- [OpenRouter Pricing](https://openrouter.ai/docs#models)

---

**Viel Erfolg! 🚀**

Bei Fragen: [Discord Community](https://discord.gg/B8KZKNsPpj)
