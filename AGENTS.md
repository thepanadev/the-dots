# AGENTS.md

This repository follows the personal docs standard defined in the canonical `docs-starter` spec:

`https://github.com/thepanadev/docs-starter/blob/main/SPEC.md`

Read this file before editing documentation.

## Scope

This file gives operational instructions to AI assistants working on documentation in this repository.

It does not restate the entire spec.

When this file and the spec appear to conflict, follow the spec for doctrinal rules and this file for repo-local operating procedure.

## Documentation contract

The documentation source lives in `docs/`.

Minimum expected files:
- `docs/index.md`
- `docs/reference/index.md`
- `mkdocs.yml`
- this `AGENTS.md` file at the repository root

Generated reference content belongs only in:

`docs/reference/_generated/`

Do not place generated output anywhere else.

## Front matter rules

Every Markdown page must include front matter with:

```yaml
title: Short page title
provenance: curated | derived | hybrid
status: draft | stable | deprecated
```

Optional fields such as `review_after`, `owner`, `source`, and `superseded_by` may be used only when they add real signal.

Do not add optional fields automatically.

## Provenance rules

### Curated

Use `curated` for pages maintained directly by editing prose.

### Derived

Use `derived` for pages generated from project artifacts.

Derived pages:
- are written only to `docs/reference/_generated/`
- are not edited by hand
- must include the standard generated-page warning admonition

### Hybrid

Use `hybrid` for curated wrapper pages that explain generated material.

Do not edit generated files directly. Create or improve a hybrid wrapper instead.

## Generated-page notice format

All generated pages must use this exact visible notice format near the top of the page:

```md
!!! warning "Generated page"
    Do not edit by hand.

    Generated at: <ISO-8601 timestamp>
    Source: `scripts/docs/generate-makefile-docs.sh`
```

## Generator layout

Generator scripts live under:

```text
scripts/
  docs/
    generate-all.sh
    generate-makefile-docs.sh
    generate-bash-docs.sh
```

Use `./scripts/docs/generate-all.sh` as the single entrypoint.

## Generation workflow

Generated files are build artifacts — do not commit them.

Before building or deploying docs, run:

```sh
./scripts/docs/generate-all.sh
```

If generated snippet targets do not exist, fix generation rather than removing snippet includes.

## Repo-local generator configuration

`generate-bash-docs.sh` has a `SCRIPT_PATTERNS` array near the top.

Current configured patterns:
- `scripts/*.sh`
- `wizard.sh`

Adjust the array when scripts are added or removed, not by editing generated output.

## MkDocs assumptions

This repo uses MkDocs Material with:
- `pymdownx.snippets` configured with `base_path: ["docs"]`
- `pymdownx.snippets` configured with `check_paths: true`
- Mermaid rendering configured through `pymdownx.superfences`

Because `check_paths: true` is enabled, missing generated files will fail the build.

## Editing rules for assistants

Do:
- preserve front matter
- update curated pages when repo intent or workflow changes
- regenerate derived pages when relevant source files change
- create hybrid wrappers when generated output needs explanation
- keep `docs/index.md` short and accurate

Do not:
- edit files under `docs/reference/_generated/` by hand
- regenerate and commit derived pages — CI runs generators on deploy; for local preview run `./scripts/docs/generate-all.sh` and leave output untracked
- invent rationale not supported by the repo
- infer Bash script purpose from filenames alone

## First local docs path

```sh
pip install mkdocs-material pymdown-extensions
./scripts/docs/generate-all.sh
mkdocs serve
```

## CI expectation

The workflow at `.github/workflows/docs.yml` follows this order:
1. install MkDocs dependencies
2. run `./scripts/docs/generate-all.sh`
3. publish with `mkdocs gh-deploy --force`

## When to update documentation

Update or regenerate docs when:
- a Makefile target is added, removed, or renamed
- a script in `scripts/` changes its purpose
- `wizard.sh` behavior changes
- the recommended first-run flow changes
