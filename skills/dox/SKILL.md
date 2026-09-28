---
name: dox
description: "Install or apply the DOX self-documenting AGENTS.md framework in a project. Use when the user wants an AGENTS.md hierarchy, asks to 'init DOX', 'add DOX', set up repo docs conventions, or when starting work in a project that lacks AGENTS.md guidance. Source: https://github.com/agent0ai/dox (MIT)."
---

# DOX — self-documenting AGENTS.md hierarchy

DOX keeps a tree of `AGENTS.md` contracts in sync with the code: a root
`AGENTS.md` holds project-wide rules and the child index; child `AGENTS.md`
files hold local rules for their subtree. Before editing, the agent walks the
docs from root to the target; after meaningful changes, it updates the
affected docs.

## Install in a project

1. Copy `AGENTS.dox.md` (next to this SKILL.md) to the target project root as
   `AGENTS.md` — merge sections if one already exists.
2. Tell the agent: `Initialize DOX tree for this project now.` It creates the
   child `AGENTS.md` files and the root index.

## Use

- Read the root `AGENTS.md`, then walk child `AGENTS.md` files along the path
  to each file you touch.
- After a change that affects scope, contracts, inputs/outputs, or structure,
  update the nearest owning `AGENTS.md` (and parents when the index changes).

Upstream: https://github.com/agent0ai/dox — MIT (LICENSE.txt alongside).
