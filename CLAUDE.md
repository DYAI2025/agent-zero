# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Agent Zero is a general-purpose AI assistant framework built on Python/Flask with a web UI. It uses a hierarchical multi-agent system where agents can delegate tasks to subordinate agents. The framework is prompt-driven—behavior is defined by markdown files in `prompts/`.

## Development Commands

```bash
# Run Web UI (default port 5000)
python run_ui.py
python run_ui.py --port=5555  # Custom port

# Installation
pip install -r requirements.txt
playwright install chromium  # Required for browser agent

# Testing
pytest -v
pytest --asyncio-mode=auto  # With async support
pytest tests/test_filename.py::test_function_name  # Single test

# Docker
docker pull agent0ai/agent-zero
docker run -p 50001:80 agent0ai/agent-zero

# Local Docker build
docker build -f DockerfileLocal -t agent-zero-local --build-arg CACHE_DATE=$(date +%Y-%m-%d:%H:%M:%S) .

# Development with RFC (for hybrid local+Docker setup)
docker run -p 8880:80 -p 8822:22 agent0ai/agent-zero
```

### Environment Configuration (`.env`)
```bash
API_KEY_OPENAI=sk-...
API_KEY_ANTHROPIC=sk-ant-...
API_KEY_GROQ=...
API_KEY_OLLAMA=http://127.0.0.1:11434
WEB_UI_PORT=5000
```

## Architecture Overview

### Entry Points
- `run_ui.py` - Flask web server (main entry point)
- `run_cli.py` - CLI interface
- `run_tunnel.py` - Remote tunnel for mobile access

### Core Components

**`agent.py`**: Core agent implementation. `AgentContext` manages execution context (chats), `Agent` handles the message loop (LLM → Tools → Memory → Response). Agents form hierarchies where Agent 0 delegates to subordinates.

**`models.py`**: LLM interface using LiteLLM for multi-provider support.

**`initialize.py`**: Startup configuration, model initialization, MCP server setup.

### Key Directories

| Directory | Purpose |
|-----------|---------|
| `python/api/` | Flask API endpoint handlers (classes inheriting `ApiHandler`) |
| `python/tools/` | Tool implementations (18 tools) |
| `python/extensions/` | Lifecycle hooks organized by extension point |
| `python/helpers/` | Utility modules (settings, memory, MCP, RFC, etc.) |
| `prompts/` | Markdown files defining agent behavior |
| `webui/` | Frontend (HTML, CSS, JS) |
| `agents/` | Agent profiles (agent0, default, developer, hacker, researcher) |
| `knowledge/` | RAG knowledge base (add files to `knowledge/custom/main/`) |
| `memory/` | Persistent agent memory |
| `instruments/` | Custom scripts callable by agents |
| `usr/projects/` | Project-specific isolated workspaces |

### Extension System

Extensions hook into agent lifecycle. Files execute in alphabetical order (use numeric prefixes like `_10_`, `_20_`).

**Extension points** in `python/extensions/`:
- `agent_init/` - Agent initialization
- `before_main_llm_call/` - Pre-LLM call modifications
- `message_loop_start/`, `message_loop_end/` - Message loop lifecycle
- `message_loop_prompts_before/`, `message_loop_prompts_after/` - Prompt processing
- `monologue_start/`, `monologue_end/` - Agent monologue lifecycle
- `response_stream/`, `response_stream_chunk/`, `response_stream_end/` - Response streaming
- `reasoning_stream/`, `reasoning_stream_chunk/`, `reasoning_stream_end/` - Reasoning output
- `tool_execute_before/`, `tool_execute_after/` - Tool execution hooks
- `system_prompt/` - System prompt processing
- `hist_add_before/`, `hist_add_tool_result/` - History management
- `error_format/` - Error formatting
- `user_message_ui/` - UI message handling
- `util_model_call_before/` - Utility model preprocessing

**Override mechanism**: Agent-specific extensions in `agents/{profile}/extensions/{point}/` override defaults by filename match.

### Tool System

Tools in `python/tools/` inherit from `Tool` base class. Tool lifecycle: `before_execution` → `execute` → `after_execution`.

Key tools:
- `code_execution_tool.py` - Python/Node.js/Shell execution (via RFC to Docker)
- `browser_agent.py` - Web browsing with vision LLM (requires `playwright install chromium`)
- `call_subordinate.py` - Delegate to subordinate agents with optional role profiles
- `memory_*.py` - Long-term memory operations (save, load, delete, forget)
- `document_query.py` - RAG-based document Q&A
- `search_engine.py` - SearXNG web search
- `response.py` - Output to user (breaks message loop)
- `behaviour_adjustment.py` - Dynamic behavior modification
- `scheduler.py` - Cron-based task scheduling
- `a2a_chat.py` - Agent-to-Agent protocol communication
- `notify_user.py` - Push notifications to user

**Override mechanism**: `agents/{profile}/tools/` overrides `python/tools/` by filename.

### Prompt System

Core prompts in root `prompts/` directory:
- `agent.system.main.md` - Central hub referencing other prompts via `{{ include }}`
- `agent.system.tool.*.md` - Individual tool definitions
- `agent.system.main.role.md` - Agent's role and capabilities

**Features**:
- Variable placeholders: `{{var}}`
- File includes: `{{ include "file.md" }}`
- Dynamic Python loaders: Create `filename.py` alongside `filename.md` to generate variables

**Custom prompts**: Create subfolder in `prompts/`, copy/modify files. Select in Settings → Agent Config.

### API Handler Pattern

```python
class MyHandler(ApiHandler):
    @staticmethod
    def requires_auth() -> bool: ...  # Web UI auth
    @staticmethod
    def requires_api_key() -> bool: ...  # External API key auth

    async def handle_request(self, request) -> Response: ...
```

Key endpoints: `message.py` (chat), `api_message.py` (external API), `chat_*.py`, `settings_*.py`, `memory_*.py`, `knowledge_*.py`, `project_*.py`, `mcp_*.py`.

### Important Helper Modules

- `settings.py` - All configuration management
- `memory.py` - Memory operations with FAISS vector DB
- `history.py` - Message history and summarization (dynamic compression)
- `mcp_handler.py`, `mcp_server.py` - MCP client/server
- `rfc.py`, `shell_ssh.py` - Remote Function Call to Docker
- `extension.py` - Extension loading and `call_extensions()` function
- `files.py` - File operations and `VariablesPlugin` base class for dynamic prompts
- `extract_tools.py` - Parse tool calls from LLM responses
- `tokens.py` - Token counting and context window management

## Development Workflow (Hybrid Mode)

For local development with full functionality:
1. Run Python framework locally in VS Code (F5 with "Debug run_ui.py")
2. Run Docker container separately with SSH port mapped
3. Configure RFC connection in Settings → Development (matching passwords)
4. Local instance delegates code execution to Docker via SSH

## Key Patterns

- **Hybrid execution**: Framework runs locally for debugging, Docker handles code execution
- **Agent hierarchy**: Agent 0 → subordinates → further subordinates
- **Context window management**: Dynamic compression/summarization of older messages
- **Projects**: Isolated workspaces with own prompts, memory, knowledge, secrets (in `usr/projects/{name}/.a0proj/`)

### MCP (Model Context Protocol)

Agent Zero supports both MCP server and client modes:
- **Server**: Expose capabilities to MCP clients (Claude Desktop, etc.)
- **Client**: Connect to external MCP servers for additional tools
- **A2A Protocol**: Agent-to-Agent communication between instances

## Prompt Engineering Patterns

- Use modular .md files with `{{ include }}` directives
- Structure content: "what it does" → "limitations" → "practical rules"
- Behavior is defined in prompts, not hardcoded
- Dynamic variable loaders: create `filename.py` alongside `filename.md` to generate variables at runtime (class must inherit `VariablesPlugin` from `python.helpers.files`)

## Agent Profiles

Profiles in `agents/` can override extensions, tools, and prompts:
```
agents/{profile}/
├── extensions/{point}/   # Override specific extensions
├── tools/                # Override specific tools
├── prompts/              # Override specific prompts
└── settings.json         # Override settings (sparse, only fields to change)
```

Built-in profiles: `agent0`, `default`, `developer`, `hacker`, `researcher`
