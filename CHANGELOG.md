# Changelog

All notable changes to this project will be documented in this file.

This project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Release notes are generated from Conventional Commits and maintained automatically.

---

## [0.2.0](https://github.com/hpowers/narrative-flow/compare/v0.1.0...v0.2.0) (2026-01-17)


### Features

* **ci:** add PR title linting workflow for conventional commits ([#3](https://github.com/hpowers/narrative-flow/issues/3)) ([2d7e8f8](https://github.com/hpowers/narrative-flow/commit/2d7e8f81302d1b8f988070bf99baa596d4b38837))
* **tooling:** add PR automation commands and scripts ([#1](https://github.com/hpowers/narrative-flow/issues/1)) ([6a6adc2](https://github.com/hpowers/narrative-flow/commit/6a6adc2ac9da796af9ac83f23317309900d1936f))
* verify release automation ([#12](https://github.com/hpowers/narrative-flow/issues/12)) ([d95a97a](https://github.com/hpowers/narrative-flow/commit/d95a97a61a4e03486a50ef9ef0546ee78650c854))
* **workflows:** add output type definitions for string and string_list in various workflows ([#10](https://github.com/hpowers/narrative-flow/issues/10)) ([2dbe5af](https://github.com/hpowers/narrative-flow/commit/2dbe5af4969fcb71706cb1f5e847723fa21d5d01))

## 0.1.0 (2026-01-15)

### Features

- Initial public release
- Workflow file format (`.workflow.md`) with YAML frontmatter
- Multi-turn conversation support
- Variable substitution with Jinja2 syntax
- Extraction steps for pulling values from responses
- OpenRouter API integration
- CLI commands: `narrative-flow run` and `narrative-flow validate`
- Markdown execution logs
- Retry logic for API failures
