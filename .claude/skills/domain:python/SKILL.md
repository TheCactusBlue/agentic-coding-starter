---
name: "domain:python"
description: "Loaded automatically when working with Python code. Defines project conventions for type hints, testing, error handling, and preferred dependencies."
---

# Python Conventions

## Idioms

- Type hints on all function signatures and class attributes
- Use f-strings for string formatting
- Prefer `dataclasses` for plain data; `pydantic.BaseModel` for validated data
- Use list/dict/set comprehensions over `map`/`filter` with lambdas
- Use context managers (`with`) for resource management
- Use `pathlib.Path` over `os.path` for filesystem operations
- Prefer `enum.Enum` for fixed sets of values
- Use `__slots__` on performance-critical classes

## Project Structure

- Use src layout: `src/<package_name>/` with `__init__.py`
- Project metadata in `pyproject.toml` — no `setup.py` or `setup.cfg`
- Use `__init__.py` to define the public API of each package
- Scripts and CLI entry points defined in `pyproject.toml`
- Configuration (ruff, pytest) lives in `pyproject.toml`

## Testing

- Use pytest as the test framework
- Test files in `tests/` mirroring `src/` structure, named `test_*.py`
- Use fixtures for setup/teardown; define shared fixtures in `conftest.py`
- Use `@pytest.mark.parametrize` for testing multiple inputs
- Prefer plain `assert` statements — pytest rewrites them for clear output
- Use `pytest.raises` for exception testing with `match` parameter

## Error Handling

- Raise specific exceptions — never bare `raise Exception(...)`
- Define custom exception hierarchies for domain errors
- Never use bare `except:` or `except Exception:` without re-raising
- Use `contextlib.suppress` for intentionally ignored exceptions
- Log exceptions with `logger.exception()` to capture tracebacks
- Let unexpected errors propagate — catch only what you can handle

## Dependencies

- **Data validation:** pydantic
- **HTTP client:** httpx (async-native, modern API)
- **Linting/formatting:** ruff (replaces flake8 + black + isort)
- **Task runner:** just or make for common commands
- **Type checking:** pyright or mypy in strict mode

## Anti-patterns

- Mutable default arguments (`def f(x=[])`) — use `None` with default in body
- Broad `except Exception` clauses that swallow errors
- Star imports (`from module import *`) — always import explicitly
- Global mutable state — pass dependencies explicitly
- Using `type: ignore` without a specific error code
- Nested functions for reusable logic — extract to module-level functions
