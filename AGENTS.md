# Global Agent Guidelines

## Local configuration
- Local dotfiles and workstation configuration are managed with chezmoi in `~/.local/share/chezmoi`.
- When working in that repo, read `~/.local/share/chezmoi/CHEZMOI_AGENTS.md` for repo-specific guidance.

## Tooling
- Some binaries are provided by asdf shims under `~/.asdf/shims`. If `which <cmd>` finds a shim but execution says no version is set, check `asdf current <tool>`, `asdf list <tool>`, and `asdf shimversions <cmd>`.
- asdf version selection depends on the current directory and nearest `.tool-versions`; use an explicit installed version via `asdf shell <tool> <version>` or run from a directory with the right `.tool-versions` when needed.

## GitHub
- The GitHub CLI (`gh`) is available; prefer it for GitHub-related tasks where appropriate, including repositories, issues, pull requests, Actions, releases, and API queries.
- Use the `github-pr-review` skill when reviewing, approving, commenting on, or editing GitHub PR reviews; the skill contains the detailed PR review workflow.

## Git
- Do not prefix branch names with an agent name such as `cursor/` or `codex/`. Descriptive prefixes like `fix/`, `feature/`, or similar are fine.

## AI Attribution
- Never include AI agent identity or attribution in user-visible output. This includes names such as `codex`, `claude code`, or similar agent identifiers in GitHub comments, PR bodies, commit messages, review responses, Jira tickets, email, documentation, or comparable external-facing text.
