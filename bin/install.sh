#!/usr/bin/env bash
#
# Skills installer — set up Skills repo for use across all projects
#
# What this does:
#   1. Merges my-skills marketplace registration into ~/.claude/settings.json
#   2. Copies agents/*.md to ~/.claude/agents/ (so agents are usable in every project)
#   3. Prints /plugin install commands you should run inside Claude Code
#
# What this does NOT do (intentional):
#   - Does not touch hooks. The hooks/common.json blocking rules vary per user, and
#     auto-merging arrays risks clobbering existing hooks. Add them manually if wanted.
#   - Does not auto-run /plugin install. Those commands are interactive in Claude Code.
#
# Usage:
#   bash bin/install.sh           # install
#   bash bin/install.sh --dry-run # preview without writing
#
# Idempotent: safe to run multiple times.

set -euo pipefail

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SKILLS_ROOT="$(cd "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd)"

USER_CLAUDE_DIR="$HOME/.claude"
USER_SETTINGS="$USER_CLAUDE_DIR/settings.json"
USER_AGENTS_DIR="$USER_CLAUDE_DIR/agents"
TEMPLATE="$SKILLS_ROOT/templates/user-settings.json.template"

color_ok()    { printf '\033[32m%s\033[0m\n' "$*"; }
color_warn()  { printf '\033[33m%s\033[0m\n' "$*"; }
color_info()  { printf '\033[36m%s\033[0m\n' "$*"; }
color_error() { printf '\033[31m%s\033[0m\n' "$*" >&2; }

if ! command -v jq >/dev/null 2>&1; then
  color_error "jq is required. Install with: brew install jq  /  apt-get install jq"
  exit 1
fi

if [[ ! -f "$TEMPLATE" ]]; then
  color_error "Template not found: $TEMPLATE"
  exit 1
fi

color_info "Skills root: $SKILLS_ROOT"
color_info "Target:      $USER_CLAUDE_DIR"
[[ $DRY_RUN -eq 1 ]] && color_warn "(dry-run mode — no files will be written)"
echo

# 1. Ensure ~/.claude and ~/.claude/agents exist
if [[ $DRY_RUN -eq 0 ]]; then
  mkdir -p "$USER_CLAUDE_DIR" "$USER_AGENTS_DIR"
fi

# 2. Merge marketplace registration into ~/.claude/settings.json
if [[ -f "$USER_SETTINGS" ]]; then
  MERGED="$(jq -s '.[0] * .[1]' "$USER_SETTINGS" "$TEMPLATE")"
  if [[ $DRY_RUN -eq 1 ]]; then
    color_info "Would merge into existing $USER_SETTINGS:"
    echo "$MERGED"
  else
    BACKUP="$USER_SETTINGS.bak.$(date +%Y%m%d-%H%M%S)"
    cp "$USER_SETTINGS" "$BACKUP"
    printf '%s\n' "$MERGED" > "$USER_SETTINGS"
    color_ok "✓ Merged my-skills marketplace into $USER_SETTINGS"
    color_info "  Backup: $BACKUP"
  fi
else
  if [[ $DRY_RUN -eq 1 ]]; then
    color_info "Would create $USER_SETTINGS from template"
  else
    cp "$TEMPLATE" "$USER_SETTINGS"
    color_ok "✓ Created $USER_SETTINGS"
  fi
fi

# 3. Copy agents (skip README.md)
AGENT_FILES=()
while IFS= read -r f; do AGENT_FILES+=("$f"); done < <(find "$SKILLS_ROOT/agents" -maxdepth 1 -name '*.md' ! -name 'README.md' | sort)
AGENT_COUNT=${#AGENT_FILES[@]}
if [[ $DRY_RUN -eq 1 ]]; then
  color_info "Would copy $AGENT_COUNT agents to $USER_AGENTS_DIR"
else
  for f in "${AGENT_FILES[@]}"; do cp "$f" "$USER_AGENTS_DIR/"; done
  color_ok "✓ Copied $AGENT_COUNT agents to $USER_AGENTS_DIR"
fi

# 4. Print next steps
echo
color_info "Next: Open Claude Code in any project and install plugins:"
echo
cat <<'EOF'
  # Anthropic official (recommended)
  /plugin install commit-commands@anthropics-claude-code
  /plugin install security-guidance@anthropics-claude-code

  # my-skills core
  /plugin install code-review@my-skills
  /plugin install playwright-test@my-skills
  /plugin install dom-explorer@my-skills

  # PdM workflow (PdM-Playbook の Skill 1〜6 をカバー)
  /plugin install pdm-voice-to-problem@my-skills
  /plugin install pdm-design-doc@my-skills
  /plugin install pdm-spec-to-prompt@my-skills
  /plugin install pdm-priority-matrix@my-skills
  /plugin install pdm-scope-management@my-skills

  # Domain-specific (お好みで)
  /plugin install vercel-deploy@my-skills
  /plugin install nextjs-mockup@my-skills
  /plugin install lp-creator@my-skills
  /plugin install report-generator@my-skills
  /plugin install municipality-data@my-skills
  /plugin install data-analysis@my-skills
  /plugin install business-email@my-skills
  /plugin install competitor-research@my-skills
  /plugin install claude-code-workflow@my-skills
EOF

echo
color_info "Per-project setup (each new project):"
echo "  cp $SKILLS_ROOT/templates/CLAUDE.md.template ./CLAUDE.md"
echo "  mkdir -p .claude/rules && cp $SKILLS_ROOT/templates/rules/*.md .claude/rules/"
echo
color_info "Optional: dangerous command blocking hooks"
echo "  Review $SKILLS_ROOT/hooks/common.json and merge into ~/.claude/settings.json manually"
echo "  (auto-merge would risk clobbering existing PreToolUse hooks)"
