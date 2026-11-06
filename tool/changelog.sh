#!/usr/bin/env bash
# Drafts a CHANGELOG.md section from the Conventional Commits since the last
# release tag (REL-6). Only user-visible types are listed: breaking changes,
# features, fixes and performance. Review and edit before committing.
# Usage: tool/changelog.sh <version> [<from-ref>]
set -euo pipefail

version="${1:?usage: tool/changelog.sh <version> [<from-ref>]}"
from="${2:-$(git describe --tags --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*' --exclude '*-rc.*' 2>/dev/null || true)}"
range="${from:+$from..}HEAD"

# Squash merges into dev make each commit one pull request; merge commits
# (release PRs into main) are skipped.
subjects=$(git log --no-merges --format='%s' "$range")

section() { # title, pattern
  local lines
  lines=$(grep -E "$2" <<< "$subjects" | sed -E 's/^[a-z]+(\(([^)]*)\))?!?: /- **\2** /; s/\*\*\*\* //' || true)
  [[ -n "$lines" ]] && printf '### %s\n\n%s\n\n' "$1" "$lines"
  return 0
}

echo "## $version - $(date +%Y-%m-%d)"
echo
section "Breaking changes" '^[a-z]+(\([^)]*\))?!: '
section "Features" '^feat(\([^)]*\))?: '
section "Fixes" '^fix(\([^)]*\))?: '
section "Performance" '^perf(\([^)]*\))?: '
