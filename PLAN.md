# Demo Plan: Bicep Snapshot Command

## Narrative

"I have a monolithic `main.bicep`, I refactor it into modules, and the snapshot proves nothing changed."

## Phase 1 — V0: Monolithic `main.bicep`

Create a single `main.bicep` with a realistic set of interconnected resources (a web app deployment):

- App Service Plan
- App Service (Web App)
- Application Insights
- Log Analytics Workspace
- Storage Account
- Key Vault with a secret (connection string reference)

All in one file — realistic but messy enough that refactoring is clearly warranted.

Also create a `main.bicepparam` file with parameter values, then run:

```sh
bicep snapshot main.bicepparam --mode overwrite
```

This generates the baseline `main.snapshot.json`. Commit as V0 on `main`.

## Phase 2 — V1: Refactored into modules

Create a branch, then break the monolith into modules:

- `modules/monitoring.bicep` — App Insights + Log Analytics
- `modules/storage.bicep` — Storage Account
- `modules/keyvault.bicep` — Key Vault + secret
- `modules/webapp.bicep` — App Service Plan + Web App
- `main.bicep` — now just wires modules together

Run snapshot again:

```sh
bicep snapshot main.bicepparam --mode overwrite
bicep snapshot main.bicepparam --mode validate
```

Commit as V1, open a PR against `main`.

## What the audience sees in the PR

- A big diff across many files (modules extracted, `main.bicep` rewritten)
- The `main.snapshot.json` is **unchanged** in the files tab, proving the refactor is safe
- A **PR comment** from CI with the `bicep snapshot --mode validate` output showing no resource changes
- This is the "aha" moment for the demo

## CI Workflows

- `deploy.yml` — deploys via `azure/bicep-deploy@v2` as a deployment stack (on push to `main`)
- `snapshot-validate.yml` — runs `bicep snapshot --mode validate` on PRs and posts the result as a PR comment

## Steps to execute

1. Create the monolithic bicep files (`main.bicep` + `main.bicepparam`)
2. Add GitHub Actions workflows (deploy + snapshot validate)
3. Initialize git repo, commit V0
4. Generate snapshot, commit the snapshot file
5. Create a feature branch
6. Refactor into modules
7. Regenerate snapshot, commit V1
8. Push and create PR
