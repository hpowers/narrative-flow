# Repository Guidelines

## Philosophy

- Prefer deterministic behavior and consistent patterns over one-off fixes.
- Use shared helpers to encode rules; avoid duplicating logic.
- Fail fast with explicit error handling and clear exception messages.
- Require local verification on every change; success means all checks pass.
- Keep the library focused: parse workflows, execute them, log results.

## Project Structure & Module Organization

- Use `narrative_flow/` as the main package with flat module structure:
  - `models.py` - Pydantic data models (workflow definitions, results, steps)
  - `parser.py` - Workflow file parsing and validation
  - `executor.py` - Workflow execution engine with retry logic
  - `logger.py` - Execution log generation and file output
  - `cli.py` - Command-line interface
  - `__init__.py` - Public API exports
- Keep `tests/` mirrored to the package structure with shared fixtures in `tests/conftest.py`.
- Store example workflows in `examples/` using `.workflow.md` extension.
- Store test workflow fixtures in `tests/workflows/`.

## Build, Test, and Development Commands

- Use `uv sync` for dependencies. Do not use `pip`, `pip install`, `pip freeze`, or `python -m venv`.
- Assume a `uv`-managed virtual environment is active for scripts/tools.
- Use the Verification Checklist for all test, lint, and pre-commit execution.

## Coding Style & Naming Conventions

- Require Python >=3.10; support 3.10, 3.11, 3.12, 3.13.
- Use Ruff formatting/linting, line length 120.
- Use type hints on all functions; prefer built-in generics (`list`, `dict`) and `int | None` unions.
- Use `def` for sync functions and `async def` for async operations.
- Require Google-style docstrings with `Args:`, `Returns:`, and `Raises:` sections.
- Use snake_case for modules/functions, PascalCase for classes, UPPER_SNAKE for constants.
- Use auxiliary verbs for booleans (e.g., `is_valid`, `has_inputs`).
- Use `lowercase_with_underscores` for directories/files.
- Use descriptive variable names.
- Use f-strings; prefer `match`/`case` for complex conditionals.
- Use guard clauses; structure try/except with `else` when returning success.
- Prefer pure functions over classes when practical; avoid duplication and favor modular design.
- Prefer `__all__` for explicit public APIs in modules.

Docstring example:

```python
def parse_workflow(source: str | Path) -> WorkflowDefinition:
    """Parse a workflow file into a WorkflowDefinition.

    Args:
        source: Path to the workflow file or workflow content as a string.

    Returns:
        A validated WorkflowDefinition ready for execution.

    Raises:
        WorkflowParseError: If the workflow file is invalid or malformed.
    """
```

## Testing Guidelines

- Use pytest with pytest-httpx for API mocking.
- Name test files `tests/test_<module>.py` mirroring the package structure.
- Store test workflow fixtures in `tests/workflows/` with descriptive names.
- Prefer small, deterministic tests; mock external I/O (OpenRouter API) in all tests.
- Cover happy paths and key failure cases.
- Centralize fixtures in `tests/conftest.py` organized by section:
  - Path fixtures
  - Workflow definition fixtures
  - Result fixtures
  - Mock response fixtures
  - Invalid workflow fixtures
- Write test docstrings explaining what behavior is being tested and why.

## Verification Checklist (Required)

```bash
# 1. Targeted tests
uv run pytest tests/test_<module>.py -v

# 2. Full suite
uv run pytest -q

# 3. Pre-commit (include untracked files)
NEW_FILES=$(git ls-files --others --exclude-standard 2>/dev/null | grep -E '\.(py|md|yaml|yml|toml|json)$' || true)
if [ -n "$NEW_FILES" ]; then
  echo "$NEW_FILES" | xargs pre-commit run --files
fi
pre-commit run --all-files
```

## Linting & Final Checks (Mandatory)

- Require the full verification checklist after ANY change (code, tests, docs, config).
- Do not skip checks because a tool timed out or failed.
- Do not assume correctness without running tests.
- Do not use IDE lint output as a substitute for real commands.
- Fix failures and re-run the full sequence until everything passes.

## Workflow File Format

Workflow files use `.workflow.md` extension with YAML frontmatter:

```yaml
---
name: workflow_identifier
description: What the workflow does
models:
  conversation: openai/gpt-4o # Main conversation model
  extraction: openai/gpt-4o-mini # Extraction model
retries: 3 # Optional, default 3
inputs:
  - name: variable_name
    description: What this input is for
    required: true # Optional, default true
    default: fallback_value # Optional
outputs:
  - name: extracted_value
    description: What this output contains
---
```

Workflow body uses Markdown headers for steps:

- `## User` or `## User:` - User message (supports `{{ variable }}` templates)
- `## Assistant` or `## Assistant:` - Expected assistant response
- `## Extract: variable_name` - Extraction step (must match an output name)

## Implementation Recipes

### Adding a new model field

- Pattern: Add field to Pydantic model with validation, update parser to extract it, add tests.
- When: Extending workflow capabilities.
- Why: Maintain separation between data models, parsing, and execution.
- Example:

```python
# In models.py
class WorkflowDefinition(BaseModel):
    """Workflow definition with all configuration."""

    name: str
    new_field: str | None = None

# In parser.py - update _parse_frontmatter()
new_field = frontmatter.get("new_field")

# In tests/test_parser.py - add test
def test_parse_workflow_with_new_field():
    """Test that new_field is correctly parsed from frontmatter."""
```

### Adding a new step type

- Pattern: Add StepType enum value, update parser detection, add executor handling.
- When: Supporting new workflow operations.
- Why: Keep step types explicit and type-safe.
- Example:

```python
# In models.py
class StepType(Enum):
    """Types of workflow steps."""

    USER = "user"
    ASSISTANT = "assistant"
    EXTRACT = "extract"
    NEW_TYPE = "new_type"  # Add new type

# In parser.py - update _parse_step()
if header.lower().startswith("new_type"):
    return Step(type=StepType.NEW_TYPE, content=content)

# In executor.py - update execute_workflow()
case StepType.NEW_TYPE:
    result = await _handle_new_type(step, context)
```

### Error handling pattern

- Pattern: Use custom exceptions with clear messages, chain exceptions properly.
- When: All validation and execution errors.
- Why: Consistent error reporting and debugging.
- Example:

```python
from narrative_flow import WorkflowParseError, WorkflowExecutionError

def validate_inputs(workflow: WorkflowDefinition, inputs: dict[str, str]) -> None:
    """Validate that all required inputs are provided.

    Args:
        workflow: The workflow definition to validate against.
        inputs: The provided input values.

    Raises:
        WorkflowExecutionError: If required inputs are missing.
    """
    missing = [
        inp.name for inp in workflow.inputs
        if inp.required and inp.name not in inputs and inp.default is None
    ]
    if missing:
        raise WorkflowExecutionError(f"Missing required inputs: {', '.join(missing)}")
```

### Template rendering

- Pattern: Use Jinja2 for variable substitution in user messages.
- When: Any step content that references input variables.
- Why: Consistent templating with clear `{{ variable }}` syntax.
- Example:

```python
from jinja2 import Template

def render_content(content: str, context: dict[str, str]) -> str:
    """Render template variables in content.

    Args:
        content: The content string with {{ variable }} placeholders.
        context: Dictionary of variable names to values.

    Returns:
        The rendered content with variables substituted.
    """
    template = Template(content)
    return template.render(**context)
```

## Public API

The library exposes these functions and classes via `narrative_flow/__init__.py`:

```python
# Main functions
parse_workflow(source: str | Path) -> WorkflowDefinition
execute_workflow(workflow, inputs, api_key=None) -> WorkflowResult
generate_log(result: WorkflowResult) -> str
save_log(result: WorkflowResult, output_dir=".", filename=None) -> Path

# Models
WorkflowDefinition, WorkflowResult, Step, StepResult, StepType
Message, InputVariable, OutputVariable, ModelsConfig

# Exceptions
WorkflowParseError, WorkflowExecutionError
```

## CLI Interface

```bash
# Validate a workflow without executing
narrative-flow validate workflow.workflow.md

# Execute a workflow
narrative-flow run workflow.workflow.md \
  --input topic="Python decorators" \
  --log-dir ./logs

# Execute with JSON inputs file
narrative-flow run workflow.workflow.md \
  --inputs-file inputs.json \
  --output-json
```

## Environment Configuration

- Set `OPENROUTER_API_KEY` environment variable for API access.
- Use `.env` file for local development (gitignored).
- Use `.envrc` for direnv support.

## Commit & Pull Request Guidelines

- Use `main` as the default branch. Use feature branches; avoid direct commits to `main`.
- Use Conventional Commits for PR titles (e.g., `feat(parser): add support for conditional steps`).
- Include summary, testing notes, and breaking changes if relevant.
- Prefer squash merges to keep history clean.

## Agent-Specific Rules

- Use `uv add <package>` / `uv remove <package>` for dependency changes.
- Keep changes focused; avoid unrelated refactoring in feature branches.
- Keep responses concise and technical.
- When modifying the public API, update `__init__.py` exports and README.md.
- When adding workflow features, add example workflows in `examples/` and test fixtures in `tests/workflows/`.
