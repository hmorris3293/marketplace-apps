# AGENTS.md

This file gives AI coding agents the shortest path to productive, safe changes in this repository.

## Scope

- Repository: Linode Marketplace Apps (Ansible playbooks + deployment StackScripts).
- Primary work areas:
  - `apps/linode-marketplace-<app>/` for app playbooks and roles
  - `deployment_scripts/linode-marketplace-<app>/` for StackScripts
  - `apps/linode_helpers/roles/` for shared helper roles
  - `tests/` for static analysis, regression tests, and performance tests

## Start Here

- Read [CLAUDE.md](CLAUDE.md) first for full standards and security requirements.
- Use [README.md](README.md), [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md), and [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) for project-level process details.
- Prefer linking to existing docs rather than duplicating long policy text in code comments or PR notes.

## High-Confidence Workflow

1. Identify the target app directory and matching deployment script.
2. Keep changes scoped to that app unless intentionally updating shared helpers.
3. Prefer Ansible modules over shell tasks whenever possible.
4. Preserve idempotency and follow existing role structure (`common` -> app role -> `post`).
5. Run focused local validation commands before finishing.

## Local Validation Commands

- Shell scripts (format + lint):
  - `./tests/static_code_analysis/shell_scripts/check_shell_scripts.sh deployment_scripts/linode-marketplace-<app>`
- YAML lint:
  - `./tests/static_code_analysis/yaml_configs/check_yaml_configs.sh apps/linode-marketplace-<app>`
- Ansible lint (file or app dir):
  - `./tests/static_code_analysis/ansible_playbooks/check_ansible_playbooks.sh apps/linode-marketplace-<app>`

Optional broader checks:

- Repository-level shellcheck parity with CI:
  - `bash .github/scripts/static-code-shellcheck.sh`
- Repository-level yamllint parity with CI:
  - `bash .github/scripts/static-code-yamllint.sh`
- Repository-level ansible-lint parity with CI:
  - `bash .github/scripts/static-code-ansible-lint.sh`

## Non-Negotiable Standards

- Do not run third-party install scripts directly (`curl | bash`). Convert operations into explicit Ansible tasks.
- Do not ship default credentials. Generate credentials during provisioning and write them to `/home/<sudo_user>/.credentials`.
- Do not expose unauthenticated ingestion/control endpoints publicly.
- Use `true`/`false` booleans in Ansible and convert StackScript UDF values to booleans explicitly.
- Ensure services are managed by systemd and app access follows repository security patterns (including TLS/reverse proxy where applicable).

## Existing Team Pipeline Skills

- Team skill orchestration is documented in [.claude/README.md](.claude/README.md).
- If using that workflow, follow the phase checkpoints and review artifacts under `.documentation/<app>/` before moving to the next phase.

## Change Boundaries

- Do not refactor unrelated apps in the same change.
- Do not rename app directories or deployment script folders unless explicitly requested.
- Keep naming conventions consistent: `linode-marketplace-<app>` across app and deployment paths.

## When Unsure

- Follow the stricter rule from [CLAUDE.md](CLAUDE.md).
- Prefer the existing pattern used by a nearby, modern app in `apps/`.
