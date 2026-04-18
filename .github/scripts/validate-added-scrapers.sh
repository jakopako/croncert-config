#!/usr/bin/env bash
set -euo pipefail

BASE_REF="${1:-${GITHUB_BASE_REF:-origin/main}}"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Error: this script must be run inside a git repository." >&2
  exit 1
fi

if ! command -v goskyr >/dev/null 2>&1; then
  echo "Error: goskyr is not installed or not on PATH." >&2
  exit 1
fi

if ! git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
  echo "Error: could not resolve base ref '$BASE_REF'." >&2
  echo "Hint: fetch the base branch/sha before running this script." >&2
  exit 1
fi

# Find newly added scraper names in config YAML diffs. Top-level scraper entries use two spaces before '- name:'.
mapfile -t scraper_names < <(
  git diff --unified=0 "$BASE_REF...HEAD" -- config/*.yml config/*.yaml \
    | awk '
      /^\+  - name:[[:space:]]*/ {
        name = $0
        sub(/^\+  - name:[[:space:]]*/, "", name)
        sub(/[[:space:]]+#.*/, "", name)

        if (name ~ /^".*"$/ || name ~ /^\047.*\047$/) {
          name = substr(name, 2, length(name) - 2)
        }

        if (length(name) > 0) {
          print name
        }
      }
    ' \
    | sort -u
)

if [[ ${#scraper_names[@]} -eq 0 ]]; then
  echo "No newly added scraper names found in config diff ($BASE_REF...HEAD)."
  exit 0
fi

echo "Found ${#scraper_names[@]} newly added scraper(s):"
for scraper_name in "${scraper_names[@]}"; do
  echo "- $scraper_name"
done

for scraper_name in "${scraper_names[@]}"; do
  echo "Running dry-run for scraper: $scraper_name"
  goskyr scrape -c config -n "$scraper_name" --dry-run
done
