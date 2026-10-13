# action-wporg-validator

Composite GitHub Action: runs WP.org Plugin Check via WP-CLI + runner MySQL (no Node/Playground).

- `action.yml` wires steps; logic lives in `scripts/*.sh` (shellcheck-clean — run `shellcheck scripts/*.sh`).
- Inputs are passed to scripts via `env:`, never interpolated into `run:` (avoids script injection).
- `wp plugin check --format=json` prints `FILE: path` + a JSON array per file, or a plain `Success:` line when clean; `run-check.sh` parses that. stderr is discarded so PHP notices don't corrupt JSON.
- MySQL: GitHub ubuntu runners ship MySQL stopped with root/root; we start it rather than require a `services:` block.
- `.github/workflows/test.yml` self-tests against `tests/fixture-plugin`. It has not been run on a real runner yet.
