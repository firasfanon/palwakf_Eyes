# Pal Eyes — Vercel Preview Git Integration Foundation V1

## Decision

GitHub remains the authoritative source and Vercel is a controlled preview
runtime. This integration does not authorize production deployment, production
aliases, production domains, database writes, Supabase apply, publication, or
public coordinates.

## Deployment path

1. A Pull Request or explicit `workflow_dispatch` starts validation.
2. GitHub Actions installs Flutter `3.38.10`.
3. Static integration verification, analyzer, and all Flutter tests run.
4. Flutter Web is compiled with `PAL_EYES_ENV=staging` and controlled OSM mode.
5. `build/web` is converted to Vercel Build Output API v3.
6. The second job deploys the prebuilt output without `--prod`.
7. The preview URL is written to the GitHub job summary.

## Secrets

These are GitHub Actions secrets and must never be committed:

- `VERCEL_TOKEN`
- `VERCEL_ORG_ID`
- `VERCEL_PROJECT_ID`

The `.vercel/` directory is local/generated and remains ignored by Git.

## Vercel project settings

- Project name: `pal-eyes`
- Team: `firasfanons-projects`
- Framework preset: Other
- Automatic Git deployments: disabled
- Deployment authority: GitHub Actions preview workflow
- Production deployment: not approved

## First bootstrap

Run `BOOTSTRAP_PAL_EYES_VERCEL_PREVIEW_PROJECT.ps1` from the updated
repository. It creates or links the Vercel project and prints the organization
and project IDs. Create a Vercel access token through the Vercel account UI,
then register all three values as GitHub Actions secrets.

## Cross-device operation

Do not transfer `.vercel/` between devices. Both devices receive integration
source through GitHub. Local `vercel link` is optional for inspection; governed
preview deployments are issued by GitHub Actions.
