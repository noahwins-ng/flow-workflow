# Implicit AC templates

Acceptance criteria that apply to a *class* of change automatically — appended by flow-sanity-check
and flow-review when `git diff --name-only <default_branch>...HEAD` matches a trigger glob, even if
the issue author didn't list them. Referenced by `profile.docs.ac_templates`.

## Infra / CI / Deploy PRs

Apply when the diff touches any of: CI/CD workflows, container/build files (`Dockerfile`,
`docker-compose.yml`), `Makefile`, root config files, or scripts invoked by CD / the prod host.

### Default AC
- CD runs green end-to-end, including the SHA + runtime-load verify gates.
- No prod drift (the deployed checkout is clean — `git status --short` on prod returns empty).
- Post-deploy smoke: one cheap real operation succeeds on prod (an API round-trip, one job run, …).

<!-- Add more classes as patterns emerge (e.g. DB migrations, public API changes). -->
