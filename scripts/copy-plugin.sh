#!/usr/bin/env bash
# Copies the plugin under test into wp-content/plugins/<slug>.
set -euo pipefail

dest="$WP_PATH/wp-content/plugins/$PLUGIN_SLUG/"
src="${GITHUB_WORKSPACE}/${BUILD_DIR%/}/"

excludes=()
while IFS= read -r pattern; do
  [ -n "$pattern" ] && excludes+=(--exclude="$pattern")
done <<< "$COPY_EXCLUDES"

mkdir -p "$dest"
rsync -a "${excludes[@]}" "$src" "$dest"
