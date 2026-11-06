#!/usr/bin/env bash
# Prints the build number for the checked-out commit: the number of commits
# in its history. It only goes up as dev and main move forward, it's the
# same for Android (versionCode) and iOS (CFBundleVersion), and anyone can
# reproduce it from the commit (REL-2). Needs full history (fetch-depth: 0).
set -euo pipefail

if [[ "$(git rev-parse --is-shallow-repository)" == "true" ]]; then
  echo "tool/build_number.sh needs the full history: check out with fetch-depth: 0" >&2
  exit 1
fi
git rev-list --count HEAD
