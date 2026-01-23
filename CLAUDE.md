# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Agent Zero is a personal, organic agentic framework that grows and learns with usage. It's a general-purpose AI assistant framework built on Python/Flask with a web UI, designed to be fully transparent and customizable. The framework uses a hierarchical multi-agent system where agents can delegate tasks to subordinate agents.

## Development Commands

### Running the Application
```bash
# Web UI (default port 5000)
python run_ui.py

# Custom port
python run_ui.py --port=5555

# Development mode (with VS Code debugger)
# Use F5 in VS Code with "Debug run_ui.py" configuration
```

### Installation
```bash
pip install -r requirements.txt
playwright install chromium  # Required for browser agent
```

### Testing
```bash
# Run all tests
pytest
pytest -v

# Run with async support
pytest --asyncio-mode=auto

# Run specific test file
pytest tests/test_filename.py

# Run specific test function
pytest tests/test_filename.py::test_function_name
```

### Docker
```bash
# Production
docker pull agent0ai/agent-zero
docker run -p 50001:80 agent0ai/agent-zero

# Local build
docker build -f DockerfileLocal -t agent-zero-local --build-arg CACHE_DATE=$(date +%Y-%m-%d:%H:%M:%S) .

# Development with RFC (SSH port 22 mapped to 8822, HTTP 80 to 8880)
docker run -p 8880:80 -p 8822:22 agent0ai/agent-zero
```

### Environment Configuration
Create a `.env` file in the root directory with API keys:
```bash
# LLM Provider API Keys
API_KEY_OPENAI=sk-...
API_KEY_ANTHROPIC=sk-ant-...
API_KEY_GROQ=...
API_KEY_DEEPSEEK=sk-...
API_KEY_OLLAMA=http://127.0.0.1:11434

# Other services
API_KEY_HUGGINGFACE=hf_...
API_KEY_GITHUB_COPILOT=...

# Optional runtime settings
A0_PERSISTENT_RUNTIME_ID=...
DEFAULT_USER_TIMEZONE=...
WEB_UI_PORT=5000
```

## Architecture Overview

### Entry Points
- `run_ui.py` - Flask web server (main entry point)
- `run_cli.py` - CLI interface for terminal usage
- `run_tunnel.py` - Remote tunnel for mobile access

### Core Components

**Agent System (`agent.py`)**: Core agent implementation with hierarchical structure. `AgentContext` manages execution context, `Agent` handles the message loop (LLM → Tools → Memory → Response).

**Models (`models.py`)**: LLM interface using LiteLLM for multi-provider support (OpenAI, Anthropic, Google, local models via Ollama).

**Initialize (`initialize.py`)**: Startup configuration, model initialization, MCP server setup.

### Key Directories

| Directory | Purpose |
|-----------|---------|
| `python/api/` | 60+ Flask API endpoint handlers (each is a class inheriting `ApiHandler`) |
| `python/tools/` | Tool implementations (18 tools: code execution, browser, memory, knowledge, etc.) |
| `python/extensions/` | Lifecycle hooks organized by extension point (10+ extension points) |
| `python/helpers/` | Utility modules (70+ helpers: LLM, memory, settings, files, MCP, RFC, etc.) |
| `prompts/` | Markdown files controlling agent behavior (prompt-driven architecture) |
| `webui/` | Frontend (HTML, CSS, JS) |
| `agents/` | Pre-defined agent profiles (_example, agent0, default, developer, hacker, researcher) |
| `knowledge/` | Knowledge base storage (RAG), add files to `knowledge/custom/main/` |
| `memory/` | Persistent agent memory (fragments, solutions, metadata) |
| `instruments/` | Custom scripts for Docker environment |
| `usr/projects/` | Project-specific data (prompts, memory, knowledge, secrets per project) |
| `logs/` | HTML chat logs for each session |
| `tmp/` | Temporary runtime data |
| `work_dir/` | Working directory for agent operations |

### Extension System

Extensions hook into agent lifecycle at these points:
- `agent_init`, `before_main_llm_call`, `message_loop_start/end`
- `message_loop_prompts_before/after`, `system_prompt`
- `response_stream`, `reasoning_stream`, `monologue_start/end`
- `tool_execute_before/after`

Extensions are loaded from `python/extensions/{point}/` and can be overridden per-agent in `agents/{profile}/extensions/{point}/`. Files execute in alphabetical order (use numeric prefixes like `_10_`, `_20_`).

Extension points in `python/extensions/`:
- `agent_init/` - Agent initialization
- `before_main_llm_call/` - Pre-LLM call modifications
- `message_loop_start/`, `message_loop_end/` - Message loop lifecycle
- `message_loop_prompts_after/` - Post-prompt processing
- `hist_add_tool_result/` - Tool result handling
- `response_stream/`, `response_stream_end/` - Response streaming
- `reasoning_stream/` - Reasoning output handling
- `user_message_ui/` - UI message processing

### Tool System

Tools in `python/tools/` inherit from `Tool` base class. All 18 tools:
- `code_execution_tool.py` - Python/Node.js/Shell execution (via RFC to Docker or local)
- `browser_agent.py` - Web browsing with vision-enabled LLM (browser-use integration)
- `call_subordinate.py` - Delegate to subordinate agents
- `memory_save.py`, `memory_load.py`, `memory_delete.py`, `memory_forget.py` - Long-term memory
- `document_query.py` - RAG-based document Q&A (knowledge base search)
- `search_engine.py` - SearXNG web search integration
- `response.py` - Output response to user
- `notify_user.py` - Send notifications
- `input.py` - Interactive keyboard input
- `behaviour_adjustment.py` - Dynamic behavior modification
- `scheduler.py` - Task scheduling and planning
- `a2a_chat.py` - Agent-to-agent communication
- `vision_load.py` - Image/vision processing
- `wait.py` - Waiting/delay tool (v0.9.7+)
- `unknown.py` - Fallback for undefined tools

Tool override mechanism:
1. Check `agents/{profile}/tools/` first
2. Fallback to `python/tools/`
3. Agent-specific tools completely replace default versions

### Prompt System

The framework is **prompt-driven** - behavior is defined by markdown files in `prompts/`:
- Core prompts are in root `prompts/` directory (not `prompts/default/`)
- `agent.system.main.md` - Central hub referencing other prompts
- `agent.system.tool.*.md` - Individual tool definitions
- `agent.system.main.role.md` - Agent's role and capabilities
- `agent.system.main.communication.md` - Communication guidelines
- `agent.system.main.solving.md` - Task-solving approach
- `agent.system.main.behaviour.md` - Dynamic behavior rules (stored in memory)
- Supports variable placeholders `{{var}}`, file includes `{{ include "file.md" }}`, and dynamic Python loaders

Custom prompts:
- Create subfolder in `prompts/` (e.g., `prompts/my-custom/`)
- Copy and modify files from root `prompts/`
- Select in Settings → Agent Config
- Custom files override default ones when names match

### API Handler Pattern

Each endpoint in `python/api/` is a class that is auto-discovered and registered:
```python
class MyHandler(ApiHandler):
    @staticmethod
    def requires_auth() -> bool  # Web UI authentication
    @staticmethod
    def requires_api_key() -> bool  # External API key authentication

    async def handle_request(self, request) -> Response
```

API endpoints include:
- `message.py` - Main chat message handling
- `api_message.py` - External API endpoint (requires API key)
- `chat_*.py` - Chat management (create, load, reset, export)
- `settings_*.py` - Settings CRUD operations
- `memory_*.py` - Memory management endpoints
- `knowledge_*.py` - Knowledge base operations
- `project_*.py` - Project management
- `backup_*.py` - Backup/restore functionality
- `scheduler_*.py` - Task scheduler endpoints
- `mcp_*.py` - MCP server endpoints
- 50+ more handlers for various features

### Important Helper Modules

Key modules in `python/helpers/`:
- `settings.py` - Settings management (63KB, handles all config)
- `memory.py` - Memory operations and vector DB (FAISS)
- `memory_consolidation.py` - AI-powered memory merging
- `history.py` - Message history and summarization
- `mcp_handler.py` - MCP client integration (46KB)
- `mcp_server.py` - MCP server implementation
- `fasta2a_server.py`, `fasta2a_client.py` - A2A protocol
- `rfc.py`, `rfc_files.py` - Remote Function Call (SSH to Docker)
- `shell_ssh.py`, `shell_local.py` - Terminal session management
- `tty_session.py` - TTY terminal interface
- `task_scheduler.py` - Background task scheduling (46KB)
- `backup.py` - Backup/restore functionality (38KB)
- `document_query.py` - RAG document processing (25KB)
- `knowledge_import.py` - Knowledge base file importing
- `projects.py` - Projects management
- `secrets.py` - Secrets storage and management
- `providers.py` - LLM provider configuration
- `vector_db.py` - FAISS vector database wrapper
- `tokens.py` - Token counting utilities
- `files.py` - File operations helper
- `extension.py` - Extension loading mechanism
- `call_llm.py` - LLM interaction wrapper

## Development Workflow

For local development with full functionality:
1. Run the Python framework locally in VS Code (with debugging)
2. Run Agent Zero Docker container separately
3. Configure RFC (Remote Function Call) connection in Settings → Development
4. Set matching RFC passwords on both instances
5. Local instance delegates code execution to Docker instance via SSH

The RFC system enables:
- Code execution in isolated Docker environment
- Access to pre-installed tools (SearXNG, etc.)
- Secure SSH communication between instances
- File synchronization between local and Docker

## Key Patterns

- **Hybrid execution**: Framework runs locally for debugging, Docker handles code execution
- **Agent hierarchy**: Agent 0 → subordinate agents → further subordinates
- **Memory with AI filtering**: Automatic memory consolidation and summarization
- **Context window management**: Dynamic compression of older messages
- **Projects**: Isolated workspaces with own prompts, memory, knowledge, secrets

### Projects System (v0.9.7+)

Projects provide isolated contexts for different use cases:
- **Location**: `/a0/usr/projects/{project_name}/.a0proj/`
- **Contains**: Custom instructions, prompts, memory, knowledge, secrets, files
- **Management**: Create/switch via Settings → Projects or Web UI
- **Isolation**: Each project has independent memory and knowledge base
- **Prompts**: Projects can override system prompts with custom versions
- **Secrets**: Project-specific secrets isolated from global secrets

### MCP (Model Context Protocol)

Agent Zero supports both MCP server and client modes:

**As MCP Server**:
- Expose Agent Zero capabilities to MCP clients (Claude Desktop, etc.)
- Endpoints automatically generated from capabilities
- Server runs on port configurable in settings

**As MCP Client**:
- Connect to external MCP servers for additional tools
- Configure in `initialize.py` or via settings
- Supports both stdio and HTTP MCP servers
- External tools integrated into agent's tool list

**A2A Protocol** (Agent-to-Agent):
- Agent Zero instances can communicate with each other
- Built on MCP foundation with streaming support
- Enables distributed agent networks

## Prompt Engineering Patterns

- Use modular .md files with `{{ include }}` directives - each principle/concept gets its own file
- Be honest about what the system actually does - no alignment theater
- Structure content: "what this actually means" → "what it is" → "what it does" → "limitations" → "practical rules"
- Never claim values/beliefs/ethics - describe mechanisms and instructions instead
