#!/usr/bin/env bash
# Checks that the store notes for the version in pubspec.yaml exist and fit
# the stores' limits (Google Play: 500 characters).
set -euo pipefail
cd "$(dirname "$0")/.."

version=$(sed -n 's/^version: *\([0-9.]*\).*/\1/p' pubspec.yaml)
notes="whats_new/$version.txt"

if [[ ! -f "$notes" ]]; then
  echo "Missing $notes: add the store notes for version $version." >&2
  exit 1
fi

length=$(wc -m < "$notes" | tr -d ' ')
if (( length > 500 )); then
  echo "$notes is $length characters; Google Play allows 500." >&2
  exit 1
fi
echo "$notes: $length characters."
