#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

BASE_SHA="${1:-}"
HEAD_SHA="${2:-}"

is_zero_sha() {
  [[ "$1" =~ ^0+$ ]]
}

collect_added_lines() {
  awk '
    /^\+\+\+ b\// {
      file = substr($0, 7)
      next
    }

    /^diff --git / || /^index / || /^--- / || /^@@ / {
      next
    }

    /^\+/ && !/^\+\+\+/ {
      if (file ~ /\.dart$/) {
        print file ":" substr($0, 2)
      }
    }
  '
}

collect_matches() {
  local pattern="$1"

  printf '%s\n' "$ADDED_LINES" \
    | grep -E "$pattern" \
    | grep -vE '^[^:]+:[[:space:]]*//' \
    || true
}

get_diff_content() {
  if [ -n "$BASE_SHA" ] && [ -n "$HEAD_SHA" ] && ! is_zero_sha "$BASE_SHA"; then
    git diff --unified=0 --no-color "$BASE_SHA" "$HEAD_SHA" -- lib test || true
    return
  fi

  if ! git diff --quiet -- lib test || ! git diff --cached --quiet -- lib test; then
    {
      git diff --unified=0 --no-color -- lib test || true
      git diff --cached --unified=0 --no-color -- lib test || true
    }
    return
  fi

  if git rev-parse --verify HEAD~1 >/dev/null 2>&1; then
    git diff --unified=0 --no-color HEAD~1 HEAD -- lib test || true
    return
  fi

  return
}

echo "Checking changed Dart lines for deprecated color APIs..."

DIFF_CONTENT="$(get_diff_content)"
ADDED_LINES="$(printf '%s\n' "$DIFF_CONTENT" | collect_added_lines)"

if [ -z "$ADDED_LINES" ]; then
  echo "No new Dart additions found to inspect."
  exit 0
fi

FOUND=0

WITH_OPACITY_MATCHES="$(collect_matches '\.withOpacity\(')"
if [ -n "$WITH_OPACITY_MATCHES" ]; then
  echo "\nForbidden pattern '.withOpacity(' found in added lines:" >&2
  echo "$WITH_OPACITY_MATCHES" >&2
  FOUND=1
fi

COLORS_MATCHES="$(collect_matches '(^|[^[:alnum:]_])Colors\.')"
if [ -n "$COLORS_MATCHES" ]; then
  echo "\nForbidden pattern 'Colors.' found in added lines:" >&2
  echo "$COLORS_MATCHES" >&2
  FOUND=1
fi

if [ $FOUND -ne 0 ]; then
  echo "\nERROR: Found deprecated color usages in newly added lines.\nReplace 'Color.withOpacity' with 'Color.withValues(alpha:)' and avoid direct 'Colors.*' in favor of Theme/AppColors." >&2
  exit 2
fi

echo "No deprecated color usages found in added lines."
