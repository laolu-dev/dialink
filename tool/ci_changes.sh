#!/usr/bin/env bash
# Sets code=true unless every changed file is documentation, so CI can skip
# the platform builds for docs-only changes. Fails safe: if the range can't be
# worked out, it reports code=true.
# Usage: BASE=<sha> HEAD=<sha> tool/ci_changes.sh
set -euo pipefail

out="${GITHUB_OUTPUT:-/dev/stdout}"
docs='^(docs/|\.github/ISSUE_TEMPLATE/|\.github/pull_request_template\.md$|[^/]*\.md$|LICENSE$)'

if [[ -z "${BASE:-}" || "$BASE" =~ ^0+$ ]] || ! files=$(git diff --name-only "$BASE...$HEAD" 2>/dev/null); then
  echo "code=true" >> "$out"; echo "No usable base; running builds."; exit 0
fi

if [[ -n "$files" ]] && ! grep -vqE "$docs" <<< "$files"; then
  echo "code=false" >> "$out"; echo "Docs-only change; skipping platform builds."
else
  echo "code=true" >> "$out"; echo "Code changed; running builds."
fi
