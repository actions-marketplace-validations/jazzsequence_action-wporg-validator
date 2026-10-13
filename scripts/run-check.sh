#!/usr/bin/env bash
# Runs `wp plugin check`, prints findings, emits GitHub annotations and
# step outputs, and fails according to $FAIL_ON.
set -uo pipefail

args=(--path="$WP_PATH" --format=json)
[ -n "${CHECKS:-}" ]              && args+=(--checks="$CHECKS")
[ -n "${EXCLUDE_CHECKS:-}" ]      && args+=(--exclude-checks="$EXCLUDE_CHECKS")
[ -n "${CATEGORIES:-}" ]          && args+=(--categories="$CATEGORIES")
[ -n "${EXCLUDE_DIRECTORIES:-}" ] && args+=(--exclude-directories="$EXCLUDE_DIRECTORIES")
[ -n "${EXCLUDE_FILES:-}" ]       && args+=(--exclude-files="$EXCLUDE_FILES")
[ "${INCLUDE_EXPERIMENTAL:-false}" = "true" ] && args+=(--include-experimental)

# stderr dropped on purpose: PHP notices would corrupt the JSON stream.
RESULTS=$(wp plugin check "$PLUGIN_SLUG" "${args[@]}" 2>/dev/null)

errors=0
warnings=0

# No findings: wp plugin check prints a plain "Success:" line, not JSON.
# Otherwise output is "FILE: path" followed by a JSON array, per file.
current_file=""
while IFS= read -r line; do
  if [[ "$line" == FILE:* ]]; then
    current_file="${line#FILE: }"
  elif [[ "$line" == \[* ]]; then
    while IFS=$'\t' read -r type lineno code message; do
      [ -z "$type" ] && continue
      if [ "$type" = "ERROR" ]; then
        errors=$((errors + 1)); level=error
      else
        warnings=$((warnings + 1)); level=warning
      fi
      echo "::${level} file=${current_file},line=${lineno}::${code}: ${message}"
    done < <(jq -r '.[] | select(.type == "ERROR" or .type == "WARNING")
      | [.type, (.line // 1), .code, (.message | gsub("&quot;"; "\"") | gsub("\n"; " "))] | @tsv' \
      <<< "$line" 2>/dev/null)
  fi
done <<< "$RESULTS"

echo "errors=$errors" >> "$GITHUB_OUTPUT"
echo "warnings=$warnings" >> "$GITHUB_OUTPUT"
echo "Plugin Check: $errors error(s), $warnings warning(s)."

case "${FAIL_ON:-warning}" in
  none)    exit 0 ;;
  error)   [ "$errors" -eq 0 ] ;;
  *)       [ $((errors + warnings)) -eq 0 ] ;;
esac
