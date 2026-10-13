# action-wporg-validator

Composite GitHub Action: runs WP.org Plugin Check via WP-CLI + runner MySQL (no Node/Playground).

- `action.yml` wires steps; logic lives in `scripts/*.sh` (shellcheck-clean — run `shellcheck scripts/*.sh`).
- Inputs are passed to scripts via `env:`, never interpolated into `run:` (avoids script injection).
- `wp plugin check --format=json` prints `FILE: path` + a JSON array per file, or a plain `Success:` line when clean; `run-check.sh` parses that. stderr is discarded so PHP notices don't corrupt JSON.
- MySQL: GitHub ubuntu runners ship MySQL stopped with root/root; we start it rather than require a `services:` block.
- `.github/workflows/test.yml` self-tests against `tests/validator-fixture` on push, PR, and weekly (Mon). The weekly run opens/updates/closes a `fixture-validation` issue; failures are usually Plugin Check wanting a newer `Tested up to`. Verified passing on a real runner (2026-10-13).

## Releases

- Merging a PR to `main` runs `auto-release-pr.yml`, which opens/updates a draft `Release X.Y.Z` PR that bumps `jazzsequence/action-wporg-validator@X.Y.Z` (and `actions/checkout@vN`) in `README.md`. Next version = latest tag + patch (first release: 1.0.0). Override with a PR title edit or a `/version X.Y.Z` comment (maintainers only).
- Merging that PR runs `create-release.yml`: tags and creates a **draft** release; publish it manually.
- Users are told to pin an exact version, not `@v1`. README pre-pins `@1.0.0`, so the first release is cut manually: run Create Release via workflow_dispatch with `1.0.0` (the auto PR sees no README diff and opens nothing). After that the automation takes over.
- Uses `GITHUB_TOKEN`, so the repo setting "Allow GitHub Actions to create and approve pull requests" must be on, and release PRs don't trigger `pull_request` workflows.
