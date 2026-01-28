# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Agent Zero is a personal, organic agentic AI framework designed to be dynamic, customizable, and extensible. It uses LLMs to accomplish tasks through code execution, web search, memory, and multi-agent cooperation. The framework is prompt-driven with no hard-coded behaviors.

## Running the Application

```bash
# Install dependencies
pip install -r requirements.txt
pip install -r requirements.dev.txt  # For development
playwright install chromium          # For browser automation

# Run web UI (default port 5000)
python run_ui.py

# Run on custom port
python run_ui.py --port=5555

# Docker (production)
docker pull agent0ai/agent-zero
docker run -p 50001:80 agent0ai/agent-zero

# Build Docker locally
docker build -f DockerfileLocal -t agent-zero-local --build-arg CACHE_DATE=$(date +%Y-%m-%d:%H:%M:%S) .
```

## Testing

```bash
# Run all tests
pytest tests/

# Run single test file
pytest tests/chunk_parser_test.py

# Run specific test function
pytest tests/chunk_parser_test.py::test_example

# Run with verbose output
pytest -v tests/
```

## Architecture

### Core Components

- **`agent.py`**: Core agent implementation (~900 lines). Contains `Agent` class with `monologue()` method as the main message loop
- **`models.py`**: LLM providers via LiteLLM
- **`run_ui.py`**: Flask web server with 60+ API endpoints
- **`initialize.py`**: Framework startup sequence

### Agent Message Loop (`agent.py:monologue()`)

```
monologue() → prepare_prompt() → call_chat_model() → process_tools() → [repeat until response_tool called]
```

Extension hooks fire at: `message_loop_start`, `before_main_llm_call`, `message_loop_end`, etc.

### Key Directories

| Directory | Purpose |
|-----------|---------|
| `python/tools/` | Built-in tools (response, code_execution, memory_*, knowledge, browser_agent, etc.) |
| `python/extensions/` | 18+ lifecycle hooks for modular functionality |
| `python/api/` | Flask API handlers (subclass ApiHandler) |
| `python/helpers/` | 40+ utility modules |
| `prompts/` | System prompts and tool prompts (Markdown) |
| `prompts/default/` | Default prompt profile |
| `agents/` | Subordinate agent profiles (developer, hacker, researcher) |
| `knowledge/` | RAG knowledge base (custom/main for user, default for system) |
| `instruments/` | Custom scripts callable by agents |
| `memory/` | Persistent agent memory storage |
| `webui/` | Frontend (HTML/JS/CSS) |

### Extension System

Extensions live in `python/extensions/{hook_name}/` and execute alphabetically:
```
python/extensions/message_loop_prompts_before/_20_behaviour_prompt.py
python/extensions/response_stream_chunk/_50_json_output.py
```

To disable: rename file with leading underscore (e.g., `browser._py`)

**Extension Points:**
- `agent_init` - Agent initialization
- `before_main_llm_call` - Before LLM API call
- `message_loop_start/end` - Message loop boundaries
- `message_loop_prompts_before/after` - Prompt processing
- `monologue_start/end` - Agent monologue boundaries
- `reasoning_stream` / `response_stream` - Stream data handlers
- `response_stream_chunk` - JSON output processing per chunk
- `system_prompt` - System prompt processing

**Extension Override:** Agent-specific extensions in `agents/{profile}/extensions/{hook}/` override defaults with same filename

### Prompt System

Prompts are Markdown files with templating:
- `{{ include "path/to/file.md" }}` - Include another prompt file
- `{{variable_name}}` - Inject variable value

Naming: `{fw|agent}.{system|message|tool}.{purpose}.md`

Core prompt: `prompts/default/agent.system.main.md`

**Dynamic Variable Loaders:** Create `{prompt_name}.py` alongside `{prompt_name}.md` with a `VariablesPlugin` subclass to generate variables at runtime:
```python
from python.helpers.files import VariablesPlugin
class MyLoader(VariablesPlugin):
    def get_variables(self, file: str, backup_dirs: list[str] | None = None) -> dict[str, Any]:
        return {"my_var": "computed_value"}
```

### API Handler Pattern

```python
class ApiHandler:
    async def process(self, input: dict, request: Request) -> dict | Response:
        pass

    @staticmethod
    def requires_auth() -> bool: ...
    @staticmethod
    def requires_api_key() -> bool: ...
```

### Tool Pattern

```python
from python.helpers.tool import Tool, Response

class MyTool(Tool):
    async def execute(self, **kwargs) -> Response:
        # Access: self.agent, self.name, self.args, self.message
        return Response(message="result", break_loop=False)
```

**Tool Lifecycle:** `before_execution()` → `execute()` → `after_execution()`

Tools need a prompt file at `prompts/default/agent.system.tool.{name}.md`

**Tool Override:** Agent-specific tools in `agents/{profile}/tools/` override defaults with same filename

## Configuration

### Environment Variables (`.env`)

```bash
OPENAI_API_KEY=...              # LLM provider keys
ANTHROPIC_API_KEY=...
WEB_UI_PORT=5000
AUTH_LOGIN=user                 # Optional web auth
AUTH_PASSWORD=pass
DEVELOPMENT=true                # Dev mode
RFC_PASSWORD=...                # Remote function call
```

### Model Providers

Configured in `conf/model_providers.yaml`. Supports 20+ providers: OpenAI, Anthropic, Google, Ollama, LM Studio, OpenRouter, etc.

## Adding New Features

**New Tool:**
1. Create `python/tools/my_tool.py` implementing Tool class
2. Add prompt `prompts/default/agent.system.tool.my_tool.md`

**New Extension:**
1. Create `python/extensions/{hook_name}/_##_my_extension.py`
2. Number prefix controls execution order

**New API Endpoint:**
1. Create `python/api/my_endpoint.py` as ApiHandler subclass
2. Automatically registered on startup

**New Agent Profile:**
1. Create `agents/my-profile/` directory
2. Add `config.yaml` and custom prompts

## Multi-Agent Hierarchy

Agents form a tree: Agent 0 (root) → subordinates. Each agent reports to its superior. The first agent's superior is the human user.

## Memory System

- **Categories**: User info, Fragments (auto-generated), Solutions, Metadata
- **Recall**: AI-filtered (not keyword search)
- **Tools**: `memory_save`, `memory_load`, `memory_delete`, `memory_forget`

## Projects

Projects provide isolated workspaces with their own prompts, memory, knowledge, files, and secrets. Located under `/a0/usr/projects/{project_name}/` with metadata in `.a0proj/`:
- `instructions/` - Auto-injected prompt files
- `memory/` - Project-scoped memory storage
- `knowledge/` - Files imported into memory
- `secrets.env` / `variables.env` - Project-specific configuration

## Debugging (VS Code)

Use `.vscode/launch.json` configurations:
- "Debug run_ui.py" - Main server (auto-enables `--development=true`)
- "Debug current file" - Any Python file

Development mode (`--development=true`) enables additional debugging output and features.

Development workflow: Local IDE for debugging + Docker for code execution isolation.

## Development Setup (Hybrid Mode)

For development, run the framework locally while connecting to Docker for code execution:
1. Run Docker container with SSH port mapped: `docker run -p 8880:80 -p 8822:22 agent0ai/agent-zero`
2. Configure RFC password in both instances via Settings > Development
3. Set SSH/HTTP ports in local instance to match Docker mapping
