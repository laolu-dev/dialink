#!/usr/bin/env bash
# Checks a pull request title against the Conventional Commits rules in
# CONTRIBUTING.md. Usage: TITLE="feat: add x" [AUTHOR=login] tool/pr_title.sh
set -euo pipefail

types='feat|fix|perf|refactor|test|docs|build|ci|chore|revert|style'
pattern="^(${types})(\([a-z0-9._/-]+\))?!?: [^A-Z].*[^.]$"

fail() { echo "::error::$1"; echo "Title: $TITLE"; exit 1; }

[[ "$TITLE" =~ $pattern ]] ||
  fail "Use '<type>(<optional scope>): <description>' with a type from: ${types//|/, }. Start the description in lowercase and don't end it with a full stop."

# Dependabot writes its own titles, which can run long.
if [[ "${AUTHOR:-}" != "dependabot[bot]" && ${#TITLE} -ge 72 ]]; then
  fail "Keep the title under 72 characters (it's ${#TITLE})."
fi

echo "OK: $TITLE"
