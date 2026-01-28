# Repository Guidelines

## Project Structure & Module Organization
`agent.py` runs the terminal agent and `run_ui.py` exposes the Flask API + web UI. Behavior-specific code sits inside `agents/`, `prompts/`, and `instruments/` with shared utilities in `python/` and `lib/`. Configuration defaults ship in `conf/`, while persisted `knowledge/`, `memory/`, and `logs/` should stay untracked. The `webui/` folder holds React-like ES modules and static assets, `docker/` contains compose files plus Dockerfiles, and all automated tests live in `tests/`.

## Build, Test, and Development Commands
- `python -m venv .venv && source .venv/bin/activate` — create and enter a local virtualenv.
- `pip install -r requirements.txt` (+ `-r requirements.dev.txt` for tooling) — install dependencies.
- `python run_ui.py --port 50001` — boot the API + UI at `http://127.0.0.1:50001`.
- `python agent.py` — start the CLI-first Agent Zero loop.
- `pytest` or `pytest tests/test_file_tree_visualize.py -k prompt` — run the suite or a focused subset.
- `docker compose -f docker/run/docker-compose.yml up -d` — run the official container with your `.env` mounted.

## Coding Style & Naming Conventions
Follow PEP 8: 4-space indentation, `snake_case` identifiers, `PascalCase` classes, and type hints for new helpers. Keep prompts declarative and self-contained; shared constants belong in `python/` modules instead of scattered literals. Web UI scripts remain ES modules with 2-space indentation and explicit exports. Name files after the capability they provide (`instruments/file_tree.py`, `webui/components/ProjectCard.js`).

## Testing Guidelines
- Add `tests/test_<module>.py` companions for every feature. Prefer pytest fixtures and patching over hard-coded paths so suites remain portable.
- Cover both success and failure flows for tools, instruments, memory access, and sandboxed commands.
- Run `pytest` before every PR and note skipped cases or new dependencies in the PR body.

## Commit & Pull Request Guidelines
- Write short imperative commits (`Add CLAUDE.md`, `Update FUNDING.yml`) and keep each change focused. Target the `development` branch unless release managers request otherwise. PRs must describe the user outcome, enumerate config or migration steps, list the test commands you ran, and attach screenshots/terminal clips for UI shifts. Tag the relevant maintainer and mention follow-up work if scope is split.

## Security & Configuration Tips
- Store secrets in `.env` (or `docker/run/env/.env` when composing) and keep them out of Git. Validate inputs before running shell commands or tool delegates, document dangerous flags in `docs/`, and prefer Docker for experiments that touch the filesystem. Watch permissions on `knowledge/` and `memory/` so automated actions cannot alter host data.
