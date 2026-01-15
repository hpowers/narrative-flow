# Contributing

Thanks for your interest in Narrative Flow! Contributions are welcome.

## Development Setup

- Install dependencies: `uv sync --extra dev` (or `pip install -e ".[dev]"` if not using uv)
- Run tests and checks using the Verification Checklist in `AGENTS.md`

## Coding Standards

- Python 3.10+ with type hints
- Ruff formatting/linting (line length 120)
- Google-style docstrings
- Favor small, deterministic tests with mocked I/O

## Pull Requests

- Use feature branches (avoid committing directly to `main`)
- Keep changes focused and well-scoped
- Include tests for new behavior and key failure cases
- Follow Conventional Commits for PR titles

## Reporting Issues

Please include:

- Clear steps to reproduce
- Expected vs. actual behavior
- Environment details (OS, Python version, package version)

## Code of Conduct

By participating, you agree to abide by the Code of Conduct in `CODE_OF_CONDUCT.md`.
