#!/usr/bin/env bash
# Installs WordPress into $WP_PATH and activates Plugin Check (+ extras).
set -euo pipefail

WP_PATH="${WP_PATH:-/tmp/wordpress}"
echo "WP_PATH=$WP_PATH" >> "$GITHUB_ENV"

wp core download --version="${WP_VERSION:-latest}" --path="$WP_PATH"

wp config create --path="$WP_PATH" \
  --dbname=wordpress_test --dbuser=root --dbpass=root --dbhost=127.0.0.1

wp core install --path="$WP_PATH" \
  --url=localhost --title=Test \
  --admin_user=admin --admin_password=admin \
  --admin_email=test@example.com --skip-email

# Word-splitting on EXTRA_PLUGINS is intentional (space-separated slugs).
# shellcheck disable=SC2086
wp plugin install plugin-check ${EXTRA_PLUGINS:-} --activate --path="$WP_PATH"
