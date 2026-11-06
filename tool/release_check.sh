#!/usr/bin/env bash
# Checks a release tag before anything is built, and prints what the release
# workflow needs. Usage: tool/release_check.sh v1.4.0-rc.1
#   - the tag is v<major>.<minor>.<patch> or v<major>.<minor>.<patch>-rc.<n>
#   - pubspec.yaml has the same <major>.<minor>.<patch>
#   - the tagged commit is on origin/main or an origin/release/* branch
# Prints version=..., prerelease=true|false (for $GITHUB_OUTPUT).
set -euo pipefail

tag="${1:?usage: tool/release_check.sh <tag>}"
fail() { echo "::error::$1" >&2; exit 1; }

[[ "$tag" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)(-rc\.[0-9]+)?$ ]] ||
  fail "Tag '$tag' isn't v<major>.<minor>.<patch> or v<major>.<minor>.<patch>-rc.<n>."
version="${BASH_REMATCH[1]}"
prerelease=false; [[ -n "${BASH_REMATCH[2]}" ]] && prerelease=true

pubspec=$(sed -nE 's/^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' pubspec.yaml)
[[ "$pubspec" == "$version" ]] ||
  fail "pubspec.yaml is at $pubspec, but the tag is for $version. Bump pubspec.yaml through a PR first."

commit=$(git rev-parse "$tag^{commit}")
on_release_branch=false
for ref in $(git for-each-ref --format='%(refname)' refs/remotes/origin/main 'refs/remotes/origin/release/*'); do
  if git merge-base --is-ancestor "$commit" "$ref"; then on_release_branch=true; break; fi
done
$on_release_branch || fail "Tag '$tag' isn't on main or a release/* branch. Tag the release merge commit on main."

[[ -f "whats_new/$version.txt" ]] || fail "whats_new/$version.txt is missing."

echo "version=$version"
echo "prerelease=$prerelease"
