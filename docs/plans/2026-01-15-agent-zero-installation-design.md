# Agent Zero: Complete Installation & Configuration Plan

## Overview

This document provides a comprehensive implementation plan for installing and configuring Agent Zero in various deployment scenarios: Docker (production), local development, and hybrid setups.

---

## Part 1: Deployment Options

### Option A: Docker Deployment (Recommended for Production)

**Best for:** End users, production environments, isolated execution

**Characteristics:**
- Single command deployment
- Pre-configured environment with all dependencies
- Includes SearXNG search, SSH server, Supervisor process manager
- Automatic isolation of code execution
- Easy updates via image pull

### Option B: Local Development Setup

**Best for:** Contributors, customization, debugging

**Characteristics:**
- Full IDE debugging support (breakpoints, variable inspection)
- Hot reload of code changes
- Requires separate Docker instance for code execution
- RFC (Remote Function Call) connection between instances

### Option C: Hybrid Development

**Best for:** Active development with production-like execution

**Characteristics:**
- Local IDE runs Python framework
- Docker container handles code execution, search, system operations
- Best of both worlds: debugging + isolated execution

---

## Part 2: Docker Installation (Production)

### Prerequisites

| Requirement | Purpose |
|-------------|---------|
| Docker Desktop or docker-ce | Container runtime |
| 4GB+ RAM | Minimum for LLM operations |
| Network access | For LLM API calls |

### Step 2.1: Install Docker

**Windows/macOS:**
1. Download Docker Desktop from docker.com
2. Run installer with default settings
3. Launch Docker Desktop

**Linux:**
```bash
# Option 1: Docker CE
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# Log out and back in

# Option 2: Docker Desktop
# Follow distribution-specific instructions at docs.docker.com
```

**macOS Extra:** Enable "Allow the default Docker socket to be used" in Docker Desktop → Settings → Advanced

### Step 2.2: Pull and Run Agent Zero

```bash
# Pull latest image
docker pull agent0ai/agent-zero

# Run with automatic port assignment
docker run -p 50001:80 agent0ai/agent-zero

# Or with specific ports and volume persistence
docker run \
  -p 50001:80 \
  -p 8822:22 \
  -v /path/to/data/memory:/a0/memory \
  -v /path/to/data/knowledge:/a0/knowledge \
  agent0ai/agent-zero
```

**Hacking Edition (Kali-based):**
```bash
docker pull agent0ai/agent-zero:hacking
docker run -p 50001:80 agent0ai/agent-zero:hacking
```

### Step 2.3: Access Web UI

1. Open `http://localhost:50001` in browser
2. Wait for initialization (watch Docker logs)
3. Configure LLM settings (see Part 4)

---

## Part 3: Local Development Installation

### Prerequisites

| Requirement | Version | Purpose |
|-------------|---------|---------|
| Python | 3.10-3.12 | Runtime |
| VS Code/Cursor/Windsurf | Latest | IDE with debugging |
| Docker | Latest | For code execution container |
| Git | Latest | Repository management |

### Step 3.1: Clone Repository

```bash
git clone https://github.com/agent0ai/agent-zero
cd agent-zero
```

### Step 3.2: Create Python Environment

```bash
# Using venv
python -m venv .venv
source .venv/bin/activate  # Linux/macOS
# or .venv\Scripts\activate  # Windows

# Using Conda
conda create -n agent-zero python=3.12
conda activate agent-zero

# Using uv
uv venv
source .venv/bin/activate
```

### Step 3.3: Install Dependencies

```bash
pip install -r requirements.txt
pip install -r requirements.dev.txt  # For testing
playwright install chromium          # Browser automation
```

### Step 3.4: Configure VS Code

The repository includes `.vscode/` with:
- `launch.json` - Debug configurations
- `extensions.json` - Recommended extensions

**Install recommended extensions:**
- `ms-python.python` - Python language support
- `ms-python.debugpy` - Python debugger
- `usernamehw.errorlens` - Error visualization

### Step 3.5: Run Local Instance

**Via VS Code:**
1. Open Debug panel (Ctrl+Shift+D)
2. Select "run_ui.py" configuration
3. Press F5

**Via Terminal:**
```bash
python run_ui.py --port=5000
```

### Step 3.6: Setup Docker Instance for Code Execution

```bash
# Run Docker instance with SSH port exposed
docker run \
  -p 8880:80 \
  -p 8822:22 \
  agent0ai/agent-zero
```

### Step 3.7: Configure RFC Connection

**In Docker instance (Settings → Development):**
- Set RFC Password: `<your-password>`
- Save settings

**In Local instance (Settings → Development):**
- RFC Password: `<same-password>`
- RFC Destination URL: `localhost`
- RFC HTTP Port: `8880`
- RFC SSH Port: `8822`
- Save settings

---

## Part 4: LLM Configuration

### Step 4.1: Choose Provider

Agent Zero supports 20+ providers via LiteLLM:

| Provider | API Key Variable | Notes |
|----------|------------------|-------|
| OpenAI | `OPENAI_API_KEY` | GPT-4, GPT-4o |
| Anthropic | `ANTHROPIC_API_KEY` | Claude models |
| Google | `GOOGLE_API_KEY` | Gemini models |
| OpenRouter | `OPENROUTER_API_KEY` | Multi-model access |
| Groq | `GROQ_API_KEY` | Fast inference |
| Mistral | `MISTRAL_API_KEY` | European provider |
| DeepSeek | `DEEPSEEK_API_KEY` | Cost-effective |
| xAI | `XAI_API_KEY` | Grok models |
| Ollama | N/A (local) | Local models |
| LM Studio | N/A (local) | Local models |

### Step 4.2: Configure Models in Web UI

Navigate to **Settings** and configure:

**Chat Model:**
- Provider: Select from dropdown
- Model Name: e.g., `gpt-4o`, `claude-sonnet-4-20250514`, `llama3.2`
- API URL: Only for Ollama/LM Studio (e.g., `http://host.docker.internal:11434`)
- Context Length: Model's max tokens
- Context Window Space: % for chat history

**Utility Model:**
- Use smaller/faster model for internal tasks
- Recommended: Same provider, smaller model

**Embedding Model:**
- Provider: OpenAI recommended (`text-embedding-3-small`)
- Used for memory and knowledge retrieval

### Step 4.3: Local Models (Ollama)

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh  # Linux
brew install ollama                             # macOS

# Pull models
ollama pull llama3.2
ollama pull qwen2.5:7b
ollama pull nomic-embed-text  # For embeddings

# Verify running
ollama list
```

**In Agent Zero Settings:**
- Provider: Ollama
- Model: `llama3.2` or `qwen2.5:7b`
- API URL: `http://host.docker.internal:11434` (Docker) or `http://localhost:11434` (local)

---

## Part 5: Authentication & Security

### Step 5.1: Web UI Authentication

**Settings → Authentication:**
- UI Login: Set username
- UI Password: Set password
- Root Password: For SSH access to container

### Step 5.2: API Keys Management

**Settings → API Keys:**
- Enter keys for your chosen providers
- Keys are stored in `.env` file or `tmp/settings.json`

### Step 5.3: Secrets Management (v0.9.5+)

Agent Zero can use credentials without exposing them to the LLM:
1. Go to **Settings → Secrets**
2. Add name/value pairs
3. Agent references secrets by name, never sees values

---

## Part 6: MCP Server Integration

### Step 6.1: Configure MCP Servers

**Via Settings UI → MCP Servers:**

Add servers as JSON array:

```json
[
  {
    "name": "sequential-thinking",
    "command": "npx",
    "args": ["--yes", "--package", "@modelcontextprotocol/server-sequential-thinking", "mcp-server-sequential-thinking"]
  },
  {
    "name": "brave-search",
    "command": "npx",
    "args": ["--yes", "--package", "@modelcontextprotocol/server-brave-search", "mcp-server-brave-search"],
    "env": {"BRAVE_API_KEY": "your-key"}
  },
  {
    "name": "remote-server",
    "type": "sse",
    "url": "https://api.example.com/mcp-sse",
    "headers": {"Authorization": "Bearer token"}
  }
]
```

### Step 6.2: Available MCP Server Types

| Type | Use Case | Required Fields |
|------|----------|-----------------|
| `stdio` | Local executables | `command`, `args` |
| `sse` | Remote SSE endpoints | `url` |
| `streaming-http` | Remote HTTP streams | `url` |

### Step 6.3: Agent Zero as MCP Server

Other MCP clients can connect to Agent Zero:

**SSE Endpoint:** `YOUR_URL/mcp/t-YOUR_API_TOKEN/sse`
**HTTP Endpoint:** `YOUR_URL/mcp/t-YOUR_API_TOKEN/http/`

---

## Part 7: External Access & Connectivity

### Step 7.1: Local Network Access

Find your computer's IP and access via:
```
http://<YOUR_IP>:<PORT>
```

### Step 7.2: Cloudflare Tunnel (Internet Access)

1. Go to **Settings → External Services**
2. Enable Cloudflare Tunnel
3. Copy provided URL
4. **Important:** Set username/password in Authentication first

### Step 7.3: External API Usage

```javascript
// Send message via API
fetch('YOUR_URL/api_message', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': 'YOUR_API_KEY'
    },
    body: JSON.stringify({
        message: "Hello",
        lifetime_hours: 24
    })
});
```

### Step 7.4: A2A (Agent-to-Agent) Protocol

Connect to other Agent Zero instances:
```
YOUR_URL/a2a/t-YOUR_API_TOKEN
```

---

## Part 8: Knowledge Base Setup

### Step 8.1: Add Custom Knowledge

Place files in `/knowledge/custom/main/` (Docker: `/a0/knowledge/custom/main/`):
- Supported: PDF, TXT, CSV, HTML, JSON, MD
- Files are automatically indexed on startup

### Step 8.2: Re-index Knowledge

Changing embedding model triggers automatic re-indexing. For manual:
1. Delete existing index files in knowledge folder
2. Restart Agent Zero

---

## Part 9: Projects Feature (v0.9.7+)

### Step 9.1: Create Project

1. Click **Projects** in sidebar
2. Create new project with:
   - Custom instructions
   - Dedicated memory
   - Project-specific secrets
   - Isolated file workspace

### Step 9.2: Project Structure

Each project maintains:
- `/projects/<name>/memory/` - Project memories
- `/projects/<name>/knowledge/` - Project knowledge
- `/projects/<name>/files/` - Project files
- Custom system instructions

---

## Part 10: Backup & Restore

### Step 10.1: Using Built-in Feature (v0.9+)

1. Go to **Settings → Backup and Restore**
2. Click **Create Backup**
3. Download backup file

### Step 10.2: Manual Backup

Backup these directories:
- `/memory/` - Agent memories
- `/knowledge/custom/` - Custom knowledge files
- `/instruments/custom/` - Custom instruments
- `/tmp/settings.json` - Configuration
- `/tmp/chats/` - Chat history

---

## Part 11: Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Port 5000 not responding | Try different port: `--port=5555` |
| RFC connection failed | Verify password matches on both instances |
| Ollama connection refused | Use `host.docker.internal` instead of `localhost` |
| Memory not persisting | Check volume mount paths |
| MCP server not loading | Check Docker logs, verify npx available |

### Verification Commands

```bash
# Check Docker container logs
docker logs <container-id>

# Test Ollama connection
curl http://localhost:11434/api/tags

# Verify Agent Zero API
curl http://localhost:50001/ping
```

---

## Part 12: Quick Start Checklist

- [ ] Install Docker Desktop
- [ ] Pull Agent Zero image: `docker pull agent0ai/agent-zero`
- [ ] Run container: `docker run -p 50001:80 agent0ai/agent-zero`
- [ ] Access Web UI: `http://localhost:50001`
- [ ] Configure Chat Model provider and API key
- [ ] Configure Utility Model (can use same provider)
- [ ] Configure Embedding Model
- [ ] Set authentication credentials
- [ ] Test with simple prompt: "What is the current date?"
- [ ] (Optional) Add MCP servers
- [ ] (Optional) Set up knowledge base
- [ ] (Optional) Create projects

---

## Appendix A: Environment Variables Reference

```bash
# LLM API Keys
OPENAI_API_KEY=...
ANTHROPIC_API_KEY=...
GOOGLE_API_KEY=...
OPENROUTER_API_KEY=...
GROQ_API_KEY=...

# Web UI
WEB_UI_PORT=5000
WEB_UI_HOST=localhost

# Authentication
AUTH_LOGIN=username
AUTH_PASSWORD=password
FLASK_SECRET_KEY=...

# Development
DEVELOPMENT=true
RFC_PASSWORD=...

# SSH (container)
SSH_PORT=8822
```

## Appendix B: Docker Compose Example

```yaml
version: '3.8'
services:
  agent-zero:
    image: agent0ai/agent-zero
    ports:
      - "50001:80"
      - "8822:22"
    volumes:
      - ./data/memory:/a0/memory
      - ./data/knowledge:/a0/knowledge/custom/main
      - ./data/instruments:/a0/instruments/custom
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
    restart: unless-stopped
```

## Appendix C: Subordinate Agent Profiles

Available in `/agents/`:
- `agent0` - Default general-purpose
- `developer` - Code-focused tasks
- `hacker` - Security/penetration testing
- `researcher` - Research and analysis
- `_example` - Template for custom agents
