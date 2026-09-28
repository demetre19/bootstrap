#!/usr/bin/env bash
#
# bootstrap/install.sh — install agent skills from pinned upstream sources.
#
# Usage:
#   ./install.sh user        # core profile: debugging, security, UI/UX, workflow
#   ./install.sh technical   # user + platform/vendor skills
#   ./install.sh             # prompts for a profile
#
# Env overrides:
#   SKILLS_DIR   where skills land (default: auto-detected below)
#   FORCE=1      reinstall even if the skill dir already exists
#
# Detection order for SKILLS_DIR:
#   1. $SKILLS_DIR                        (explicit override)
#   2. $HOME/.claude/skills               (Claude Code)
#   3. $HOME/.agents/skills               (agents.md / open harness convention)
#   4. $HOME/.codex/skills                (Codex)
#   5. $HOME/.omp/agent/custom-skills     (OMP)
#   Falls back to ./skills-out if none exist — symlink it wherever your
#   runtime reads skills.
#
set -euo pipefail
cd "$(dirname "$0")"

PROFILE="${1:-}"
if [ -z "$PROFILE" ]; then
  echo "Profiles:"
  echo "  user       — debugging, security scans, UI/UX, ponytail, writing helpers"
  echo "  technical  — everything in user + cloudflare, supabase, github, dataforseo, last30days"
  printf "Install which profile? [user/technical] "
  read -r PROFILE
fi
case "$PROFILE" in user|technical) ;; *) echo "Unknown profile: $PROFILE"; exit 1;; esac

pick_dir() {
  if [ -n "${SKILLS_DIR:-}" ]; then echo "$SKILLS_DIR"; return; fi
  for d in "$HOME/.claude/skills" "$HOME/.agents/skills" "$HOME/.codex/skills" "$HOME/.omp/agent/custom-skills"; do
    [ -d "$d" ] && { echo "$d"; return; }
  done
  echo "$(pwd)/skills-out"
}
DEST="$(pick_dir)"
mkdir -p "$DEST"
echo "Installing '$PROFILE' profile → $DEST"
echo

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

fetch_repo() { # fetch_repo <repo> <sha> — downloads + extracts once, echoes dir
  local repo="$1" sha="$2"
  local key out
  key="$(echo "$repo" | tr '/.' '__')-$sha"
  out="$TMP/$key"
  if [ ! -d "$out" ]; then
    curl -fsSL "https://github.com/$repo/archive/$sha.tar.gz" | tar -xz -C "$TMP"
    mv "$TMP/$repo-$sha" "$out" 2>/dev/null || mv "$TMP"/"$(basename "$repo")-$sha" "$out"
  fi
  echo "$out"
}

install_skill() { # install_skill <name> <src|local> <subpath> <sha>
  local name="$1" src="$2" sub="$3" sha="$4"
  if [ -d "$DEST/$name" ] && [ -z "${FORCE:-}" ]; then
    printf '  - %-38s already installed\n' "$name"; return 0
  fi
  if [ "$src" = "local" ]; then
    rm -rf "$DEST/$name" && cp -R "skills/$name" "$DEST/$name"
    printf '  + %-38s bundled\n' "$name"; return 0
  fi
  local repo_dir skill_dir
  repo_dir="$(fetch_repo "$src" "$sha")"
  if [ "$sub" = "." ]; then skill_dir="$repo_dir"; else skill_dir="$repo_dir/$sub"; fi
  if [ ! -f "$skill_dir/SKILL.md" ]; then
    printf '  ! %-38s MISSING at %s — skipped\n' "$name" "$src/$sub"; return 1
  fi
  rm -rf "$DEST/$name" && cp -R "$skill_dir" "$DEST/$name"
  printf '  + %-38s %s\n' "$name" "$src"
}

# --- manifest: profile | skill | source | subpath | sha ----------------
# SHAs pinned 2026-09-29. Bump deliberately.
install_skills() {
  local profile="$1"; shift
  for line in "$@"; do
    local prof name src sub sha
    IFS='|' read -r prof name src sub sha <<< "$line"
    [ -z "$prof" ] && continue
    if [ "$prof" = "user" ] || [ "$prof" = "$profile" ]; then
      install_skill "$name" "$src" "$sub" "$sha"
    fi
  done
}

OP="5fd93af4cd0c623e020d0cc7e9ce178b4ac1f70f"   # openai/plugins
OS="49f948faa9258a0c61caceaf225e179651397431"   # openai/skills
UX="fd237335991c0f96c01da25ea81f5c7b580d8f71"   # notsonata/uiux-engine (MIT)
PT="e3ba2aa6f1e6f0bc4d69eb09c9f0d0a93af56156"   # DietrichGebert/ponytail (MIT)
IM="114ea1d3838fca73b253af45f873b9c4f5f213c8"   # pbakaus/impeccable
L3="084662b501fb0dba95bd55eff0c258d35e0dc499"   # mvanhorn/last30days-skill
NM="50ea98d8157e49a003d65e31f3807a8f29077f9a"   # kunchenguid/no-mistakes (MIT)

install_skills "$PROFILE" \
  "user|debug-deep|local|.|" \
  "user|error-finder|local|.|" \
  "user|ux-purpose-audit|local|.|" \
  "user|design-direction-questionnaire|local|.|" \
  "user|micro-interactions|local|.|" \
  "user|autoimprove|local|.|" \
  "user|website-copy|local|.|" \
  "user|security-scan|openai/plugins|plugins/codex-security/skills/security-scan|$OP" \
  "user|security-diff-scan|openai/plugins|plugins/codex-security/skills/security-diff-scan|$OP" \
  "user|deep-security-scan|openai/plugins|plugins/codex-security/skills/deep-security-scan|$OP" \
  "user|security-and-hardening|local|.|" \
  "user|propose-security-hardening|openai/plugins|plugins/codex-security/skills/propose-security-hardening|$OP" \
  "user|attack-path-analysis|openai/plugins|plugins/codex-security/skills/attack-path-analysis|$OP" \
  "user|threat-model|openai/plugins|plugins/codex-security/skills/threat-model|$OP" \
  "user|finding-discovery|openai/plugins|plugins/codex-security/skills/finding-discovery|$OP" \
  "user|triage-finding|openai/plugins|plugins/codex-security/skills/triage-finding|$OP" \
  "user|fix-finding|openai/plugins|plugins/codex-security/skills/fix-finding|$OP" \
  "user|track-findings|openai/plugins|plugins/codex-security/skills/track-findings|$OP" \
  "user|validation|openai/plugins|plugins/codex-security/skills/validation|$OP" \
  "user|ponytail|DietrichGebert/ponytail|skills/ponytail|$PT" \
  "user|ponytail-review|DietrichGebert/ponytail|skills/ponytail-review|$PT" \
  "user|ponytail-audit|DietrichGebert/ponytail|skills/ponytail-audit|$PT" \
  "user|ponytail-debt|DietrichGebert/ponytail|skills/ponytail-debt|$PT" \
  "user|ponytail-gain|DietrichGebert/ponytail|skills/ponytail-gain|$PT" \
  "user|ponytail-help|DietrichGebert/ponytail|skills/ponytail-help|$PT" \
  "user|impeccable|pbakaus/impeccable|.claude/skills/impeccable|$IM" \
  "user|ux-auditor|notsonata/uiux-engine|skills/ux-auditor|$UX" \
  "user|ux-intent-discovery|notsonata/uiux-engine|skills/ux-intent-discovery|$UX" \
  "user|design-system|notsonata/uiux-engine|skills/design-system|$UX" \
  "user|information-hierarchy|notsonata/uiux-engine|skills/information-hierarchy|$UX" \
  "user|form-ux|notsonata/uiux-engine|skills/form-ux|$UX" \
  "user|feedback-and-affordance|notsonata/uiux-engine|skills/feedback-and-affordance|$UX" \
  "user|state-completeness|notsonata/uiux-engine|skills/state-completeness|$UX" \
  "user|visual-character|notsonata/uiux-engine|skills/visual-character|$UX" \
  "technical|cloudflare|openai/plugins|plugins/cloudflare/skills/cloudflare|$OP" \
  "technical|cloudflare-deploy|openai/skills|skills/.curated/cloudflare-deploy|$OS" \
  "technical|wrangler|openai/plugins|plugins/cloudflare/skills/wrangler|$OP" \
  "technical|workers-best-practices|openai/plugins|plugins/cloudflare/skills/workers-best-practices|$OP" \
  "technical|supabase|openai/plugins|plugins/supabase/skills/supabase|$OP" \
  "technical|supabase-postgres-best-practices|openai/plugins|plugins/supabase/skills/supabase-postgres-best-practices|$OP" \
  "technical|yeet|openai/skills|skills/.curated/yeet|$OS" \
  "technical|gh-address-comments|openai/skills|skills/.curated/gh-address-comments|$OS" \
  "technical|gh-fix-ci|openai/skills|skills/.curated/gh-fix-ci|$OS" \
  "technical|no-mistakes|kunchenguid/no-mistakes|skills/no-mistakes|$NM" \
  "technical|dataforseo|local|.|" \
  "technical|last30days|mvanhorn/last30days-skill|skills/last30days|$L3"

echo
echo "Done. Restart your agent session to pick up new skills."
