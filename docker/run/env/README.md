# Environment File Placement

- Store your runtime `.env` in this folder as `docker/run/env/.env`.
- `docker-compose.yml` loads the file and bind-mounts it into the container at `/a0/.env` so settings persist across rebuilds.
- Move or copy your existing root-level `.env` here before running `docker compose up` to reuse your credentials and keys.
