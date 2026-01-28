# Agent Zero - QWEN Context

## Project Overview

Agent Zero is a personal, organic agentic framework that grows and learns with you. It's designed to be dynamic, organically growing, and learning as you use it. Unlike predefined agentic frameworks, Agent Zero is fully transparent, readable, comprehensible, customizable, and interactive. It uses the computer as a tool to accomplish tasks.

### Key Features

1. **General-purpose Assistant**: Not pre-programmed for specific tasks but meant to be a general-purpose personal assistant. It has persistent memory allowing it to memorize previous solutions, code, facts, instructions, etc.

2. **Computer as a Tool**: Uses the operating system as a tool to accomplish tasks. It can write its own code and use the terminal to create and use its own tools as needed.

3. **Multi-agent Cooperation**: Every agent has a superior agent giving it tasks and instructions. Every agent can create subordinate agents to help break down and solve subtasks.

4. **Completely Customizable and Extensible**: Almost nothing is hard-coded. The whole behavior is defined by system prompts in the `prompts/default/agent.system.md` file.

5. **Communication is Key**: Agents can communicate with their superiors and subordinates, asking questions, giving instructions, and providing guidance.

## Architecture

### Core Components

- **agent.py**: Orchestrates agent contexts and serves as the terminal entrypoint
- **run_ui.py**: Starts the Flask API and web UI
- **models.py**: Handles model configuration and integration with LiteLLM
- **initialize.py**: Contains initialization logic for agents and services
- **python/**: Runtime helpers and core functionality
- **prompts/**: Behavior and prompt definitions
- **agents/**: Agent-specific configurations
- **instruments/**: Custom tools and functions
- **webui/**: Frontend assets and components

### Agent Context System

The framework uses an `AgentContext` system that manages different agent contexts, each with:
- Unique ID and name
- Configuration settings
- Logging capabilities
- Agent hierarchy (superior/subordinate relationships)

### Tool System

Agent Zero has a flexible tool system where:
- Default tools include online search, memory features, communication, and code/terminal execution
- Custom tools can be created in the `python/tools/` directory
- Tools are dynamically loaded based on agent configuration
- MCP (Model Context Protocol) tools can be integrated

## Building and Running

### Prerequisites

- Python 3.10+
- Docker (recommended for isolation)

### Installation Methods

#### Docker Method (Recommended)
```bash
# Pull and run with Docker
docker pull agent0ai/agent-zero
docker run -p 50001:80 agent0ai/agent-zero

# Visit http://localhost:50001 to start
```

#### Local Installation
```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
pip install -r requirements.dev.txt  # for development

# Run the web UI
python run_ui.py --port 50001

# Or run in terminal mode
python agent.py
```

### Configuration

Configuration is primarily handled through:
- Environment variables (`.env` file)
- Settings in the web UI
- YAML configuration files in `conf/` directory
- Prompt templates in `prompts/` directory

## Development Conventions

### Python Code Style
- Follow PEP 8 guidelines
- Use 4-space indents
- Use `snake_case` for functions and variables
- Use `PascalCase` for classes
- Include type hints and concise docstrings

### Project Structure
- Core logic in `python/` directory
- Tools in `python/tools/`
- API handlers in `python/api/`
- Extensions in `python/extensions/`
- Helper functions in `python/helpers/`

### Testing
- Tests are located in the `tests/` directory
- Use pytest for testing
- Run tests with: `pytest`
- Target specific tests: `pytest tests/test_specific_file.py`

### Security Considerations
- Agent Zero can perform dangerous actions, so run in isolated environments
- Use Docker for safer execution
- Be careful with what tasks you assign to the agent
- Manage secrets properly using the secrets management system

## Key Technologies

- **LiteLLM**: For LLM provider abstraction
- **Flask**: For the web UI and API server
- **LangChain**: For LLM integrations
- **Docker**: For containerization and isolation
- **Playwright**: For browser automation
- **FAISS**: For vector storage and similarity search
- **Paramiko**: For SSH connections

## Extensibility

### Creating Custom Tools
1. Create a new Python file in `python/tools/`
2. Inherit from the `Tool` base class
3. Implement the required methods
4. The tool will be automatically discovered and loaded

### Modifying Agent Behavior
1. Modify prompts in the `prompts/` directory
2. The main system prompt is in `prompts/agent.system.main.md`
3. Different aspects of behavior are controlled by various prompt files

### Adding Extensions
1. Create extension files in `python/extensions/`
2. Extensions can hook into various points of the agent lifecycle
3. Use the extension system to modify agent behavior without changing core code

## Projects Feature

Agent Zero supports Projects - isolated workspaces with their own:
- Prompts
- Files
- Memory
- Secrets
- Settings

This allows creating dedicated setups for each use case without mixing contexts.

## MCP (Model Context Protocol) Support

Agent Zero can act as both MCP Server and Client, allowing integration with external tools and services that support the MCP protocol.

## Troubleshooting

Common issues and solutions:
- Check the logs in the `logs/` directory
- Verify API keys and model configurations
- Ensure proper environment setup
- Check Docker container resources if using Docker
- Review rate limits on API providers

## Important Notes

- Agent Zero can be dangerous as it can perform many actions on your computer
- Always run in an isolated environment
- The framework is prompt-based, so the `prompts/` folder controls all behavior
- No coding is required from the user perspective - only prompting and communication skills