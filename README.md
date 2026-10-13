# action-wporg-validator

Run the [WordPress.org Plugin Check](https://wordpress.org/plugins/plugin-check/) in GitHub Actions **without Node or WP Playground**.

The official action boots a Node runtime just to launch WP Playground, which then installs Plugin Check. This action skips that: it installs a real WordPress with WP-CLI against the runner's preinstalled MySQL, activates `plugin-check`, and runs `wp plugin check`. Findings are emitted as GitHub annotations.

## Usage

```yaml
jobs:
  plugin-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: jazzsequence/action-wporg-validator@0.0.0
        with:
          slug: my-plugin
```

## Inputs

| Input | Default | Description |
|---|---|---|
| `slug` | repo name | Plugin directory name |
| `build-dir` | `.` | Plugin location relative to the workspace |
| `php-version` | `8.2` | PHP version |
| `wp-version` | `latest` | WordPress version |
| `extra-plugins` | | Space-separated slugs to install/activate (dependencies) |
| `checks` / `exclude-checks` / `categories` | | Passed to `wp plugin check` |
| `exclude-directories` | `vendor,node_modules,tests,bin,.github` | Passed to `wp plugin check` |
| `exclude-files` | `.gitignore,.distignore` | Passed to `wp plugin check` |
| `copy-excludes` | `.git`, `node_modules` | rsync excludes when copying the plugin |
| `include-experimental` | `false` | Run experimental checks |
| `fail-on` | `warning` | `error`, `warning`, or `none` |

## Outputs

`errors`, `warnings` — finding counts.