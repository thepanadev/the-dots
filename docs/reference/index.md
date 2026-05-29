---
title: Reference
provenance: hybrid
status: stable
---

# Reference

This section combines short curated guidance with generated reference pages built from the Makefile and scripts.

Run `./scripts/docs/generate-all.sh` before building the docs locally.

## Make Targets

`make the-dots` is the safe default — it presents a menu of all targets so you never have to remember individual commands. Use narrower targets directly when you know exactly which slice you want.

--8<-- "reference/_generated/make-targets.md"

## Bash Scripts

Scripts in `scripts/` are invoked by Make targets; most are not meant to be called directly. `wizard.sh` and `scripts/the-dots.sh` are the two TUI entrypoints.

--8<-- "reference/_generated/bash-scripts.md"
