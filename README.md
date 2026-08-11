# BigDataMining

Shared repo for the **Mineração de Grandes Bases de Dados** (2026.2 – USP) coursework. Course projects live as Jupyter notebooks under [`projects/`](projects), backed by a local PostgreSQL database.

## Stack

- **Python 3.13** — dependencies and virtual env managed with [`uv`](https://docs.astral.sh/uv/)
- **PostgreSQL 18** — runs locally via Docker Compose
- **Jupyter / ipykernel** — notebooks, `pandas`, `matplotlib`, `sqlalchemy` for querying the DB

## Prerequisites

- [`uv`](https://docs.astral.sh/uv/getting-started/installation/) installed
- [Docker](https://docs.docker.com/get-docker/) + Docker Compose installed

## Getting started

```bash
# 1. Clone the repo
git clone <repo-url>
cd BigDataMining

# 2. Install Python deps (creates .venv automatically, using Python 3.13)
uv sync

# 3. Start the PostgreSQL database
docker compose up -d

# 4. Launch Jupyter and open a notebook from projects/
uv run jupyter notebook
```

The database is reachable at `localhost:5432` with the credentials defined in [`compose.yml`](compose.yml) (user `myuser`, password `mysecretpassword`, db `mydatabase`). Adjust those values there if needed — they're for local dev only, not committed secrets for production use.

To stop the database: `docker compose down` (add `-v` to also wipe the stored data).

## Project structure

```
.
├── compose.yml       # Postgres service for local development
├── pyproject.toml    # Python project + dependencies (managed by uv)
├── projects/          # Coursework notebooks (one per assignment/project)
└── LICENSE
```

## Working on the project

- Add new dependencies with `uv add <package>` — this updates `pyproject.toml` and `uv.lock` automatically.
- Keep new coursework notebooks inside `projects/`.
- `uv.lock` is committed so everyone resolves the exact same dependency versions — don't edit it by hand.

## License

MIT — see [LICENSE](LICENSE).
