# action-wporg-validator

Composite GitHub Action: runs WP.org Plugin Check via WP-CLI + runner MySQL (no Node/Playground).

- `action.yml` wires steps; logic lives in `scripts/*.sh` (shellcheck-clean — run `shellcheck scripts/*.sh`).
- Inputs are passed to scripts via `env:`, never interpolated into `run:` (avoids script injection).
- `wp plugin check --format=json` prints `FILE: path` + a JSON array per file, or a plain `Success:` line when clean; `run-check.sh` parses that. stderr is discarded so PHP notices don't corrupt JSON.
- MySQL: GitHub ubuntu runners ship MySQL stopped with root/root; we start it rather than require a `services:` block.
- `.github/workflows/test.yml` self-tests against `tests/validator-fixture` on push, PR, and weekly (Mon). The weekly run opens/updates/closes a `fixture-validation` issue; failures are usually Plugin Check wanting a newer `Tested up to`. Verified passing on a real runner (2026-10-13).
