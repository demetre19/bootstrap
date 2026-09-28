# Agent bootstrap

Drop-in skill pack for AI coding agents. Clone this repo, pick a profile, run
`install.sh`. Everything installs as standard `SKILL.md` folders under your
agent's skills directory.

## Quick start

```bash
git clone https://github.com/demetre19/bootstrap.git
cd bootstrap
./install.sh            # asks which profile you want
```

## Profiles

### `user` — everyday coding partner (33 skills)

The general-purpose set. Debugging, security review, UI/UX quality gates,
and ruthless-scope discipline. No vendor credentials required.

| Group | Skills |
|---|---|
| **Debug** | `debug-deep`, `error-finder` |
| **Security** | `security-scan`, `security-diff-scan`, `deep-security-scan`, `security-and-hardening`, `propose-security-hardening`, `attack-path-analysis`, `threat-model`, `finding-discovery`, `triage-finding`, `fix-finding`, `track-findings`, `validation` |
| **Ponytail** (scope discipline) | `ponytail`, `ponytail-review`, `ponytail-audit`, `ponytail-debt`, `ponytail-gain`, `ponytail-help` |
| **UI/UX** | `impeccable`, `ux-auditor`, `ux-intent-discovery`, `ux-purpose-audit`, `design-system`, `design-direction-questionnaire`, `information-hierarchy`, `form-ux`, `feedback-and-affordance`, `state-completeness`, `micro-interactions`, `visual-character`, `website-copy` |
| **Workflow** | `autoimprove` |

### `technical` — adds platform & vendor skills (45 total)

Everything in `user`, plus skills that assume provider accounts, CLIs, or
paid APIs:

| Group | Skills |
|---|---|
| **Cloudflare** | `cloudflare`, `cloudflare-deploy`, `wrangler`, `workers-best-practices` |
| **Supabase** | `supabase`, `supabase-postgres-best-practices` |
| **GitHub** | `yeet`, `gh-address-comments`, `gh-fix-ci` |
| **Research** | `last30days` (optional API keys for some sources), `dataforseo` (needs a DataForSEO login) |
| **Pipeline** | `no-mistakes` |

## Where skills land

`install.sh` writes to the first directory that exists, in order:

1. `$SKILLS_DIR` (explicit override — set this first if you know the path)
2. `~/.claude/skills` — Claude Code
3. `~/.agents/skills` — agents.md / cross-harness convention
4. `~/.codex/skills` — Codex
5. `~/.omp/agent/custom-skills` — OMP
6. `./skills-out` — fallback, symlink it into your runtime

After installing, restart your agent session so the skills register.

## Sources

| Repo | Supplies | License |
|---|---|---|
| `openai/plugins` `plugins/codex-security/` | security scan suite | Apache-2.0 |
| `openai/plugins` `plugins/cloudflare/` | `cloudflare`, `wrangler`, `workers-best-practices` | Apache-2.0 |
| `openai/plugins` `plugins/supabase/` | `supabase`, `supabase-postgres-best-practices` | Apache-2.0 |
| `openai/skills` `skills/.curated/` | `yeet`, `gh-address-comments`, `gh-fix-ci`, `cloudflare-deploy` | Apache-2.0 |
| `DietrichGebert/ponytail` | ponytail suite | MIT |
| `notsonata/uiux-engine` | UX/audit/design skills | MIT |
| `pbakaus/impeccable` | `impeccable` | upstream license |
| `mvanhorn/last30days-skill` | `last30days` | upstream license |
| `kunchenguid/no-mistakes` | `no-mistakes` | MIT |
| **bundled in this repo** | `debug-deep`, `error-finder`, `security-and-hardening`, `ux-purpose-audit`, `micro-interactions`, `autoimprove`, `design-direction-questionnaire`, `website-copy`, `dataforseo` | see each folder |

All upstream pins are commit SHAs in `install.sh`. Bump them deliberately.

## Re-running

Safe to re-run: existing skills are skipped. `FORCE=1 ./install.sh <profile>`
reinstalls everything from the pinned SHAs.
