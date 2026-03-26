# Project Instructions

## Stack
Python 3.12, FastAPI, SQLAlchemy, Alembic, pytest, Pydantic

## Commands
- `uvicorn app.main:app --reload` — start dev server
- `pytest -v` — run tests
- `ruff check .` — lint
- `ruff format .` — format
- `mypy .` — type check
- `alembic upgrade head` — run migrations
- `alembic revision --autogenerate -m "description"` — create migration

## Architecture
- `app/` — application root
  - `main.py` — FastAPI app, middleware, startup
  - `api/` — route handlers grouped by domain
  - `models/` — SQLAlchemy models
  - `schemas/` — Pydantic request/response schemas
  - `services/` — business logic layer
  - `repositories/` — data access layer
  - `core/` — config, security, dependencies
- `tests/` — mirrors app/ structure
- `alembic/` — database migrations

## Critical Constraints
- Type hints on all public functions (use `X | None` not `Optional[X]`)
- Pydantic for external data, dataclasses for internal domain objects
- Never use bare `except Exception` — always specify the exception type
- All database operations go through the repository layer, not directly in routes
- Use dependency injection via FastAPI's Depends()
