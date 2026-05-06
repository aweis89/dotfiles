# github-pr-review

Use this skill when reviewing GitHub pull requests, approving PRs, leaving PR review comments, editing previous PR review comments, or verifying GitHub review state with the `gh` CLI.

## Principles

- The GitHub CLI (`gh`) is available; use it for GitHub-related tasks where appropriate.
- For PR review workflows, use the `gh` CLI unless the user explicitly asks otherwise.
- Keep approvals and comments accurate: approve only PRs that were reviewed and found acceptable; comment only on PRs with unresolved issues.
- Before commenting on a problematic PR or changing PR review state, first raise the issues in chat and wait for the user to explicitly ask you to submit the review/comment/state change.
- After submitting approvals/comments, verify the resulting state with `gh pr view <pr> --json reviews`.
- Avoid fragile inline shell quoting for review bodies, especially when comments include Markdown, backticks, `${...}`, `<...>`, apostrophes, or multiline text.
- Prefer quoted heredocs, temp files, or JSON `--input` payloads for review/comment body text.

## Inspecting PRs

From the checked-out repo directory:

```bash
gh pr view <pr> --json title,author,baseRefName,headRefName,body,files,commits,mergeable,url,reviews
gh pr diff <pr> --patch
```

For multiple PRs in the same repo:

```bash
for pr in 123 124 125; do
  echo "===== PR $pr VIEW ====="
  gh pr view "$pr" --json title,author,baseRefName,headRefName,body,files,commits,mergeable,url
  echo "===== PR $pr DIFF ====="
  gh pr diff "$pr" --patch
done
```

If deeper validation is needed, fetch PR refs locally without changing the user's current branch:

```bash
git fetch origin pull/<pr>/head:review-pr-<pr> --force
git show review-pr-<pr>:path/to/file | nl -ba | sed -n '1,120p'
```

## Approving good PRs

Use `gh pr review --approve` with a concise body:

```bash
gh pr review <pr> --approve -b "Reviewed the changes; LGTM."
```

After approving, verify your review state:

```bash
gh pr view <pr> --json reviews --jq '.reviews[] | select(.author.login=="'"'$(gh api user --jq .login)'"'") | [.state,.submittedAt,.body] | @tsv'
```

A simpler verification is often enough:

```bash
gh pr view <pr> --json reviews --jq '.reviews[] | [.author.login,.state,.body] | @tsv'
```

## Commenting on problematic PRs

Before submitting a comment or changing the PR review state, summarize the issues in chat and wait for the user to explicitly ask you to comment, approve, request changes, or otherwise submit a review.

For short one-line comments:

```bash
gh pr review <pr> --comment -b "Found one issue: ..."
```

For multiline comments, avoid inline quoting and use a variable loaded from a single-quoted heredoc:

```bash
body=$(cat <<'EOF'
Thanks for the update. I found one issue:

`some.value` renders incorrectly when ...

Please update it so the rendered result is closer to:

`expected/value:<tag>`
EOF
)

gh pr review <pr> --comment -b "$body"
```

If the body contains shell-sensitive text like `${var.aws_region}`, the heredoc delimiter must be quoted (`<<'EOF'`) so Bash does not expand it.

## Avoid literal `\n` formatting mistakes

Do not pass multiline Markdown as escaped `\n` inside a normal quoted string unless you are deliberately using a mechanism that interprets escapes. This can create comments with literal `\n` text.

Bad:

```bash
gh pr review <pr> --comment -b "Line one\n\nLine two"
```

Better:

```bash
body=$(cat <<'EOF'
Line one

Line two
EOF
)
gh pr review <pr> --comment -b "$body"
```

## Updating an existing submitted PR review body

GitHub submitted review bodies can be edited through the GitHub API. Use `PUT`, not `PATCH`.

1. Find the review ID:

```bash
gh api repos/OWNER/REPO/pulls/<pr>/reviews \
  --jq '.[] | {id,user:.user.login,state,body,submitted_at}'
```

2. Prefer a JSON input file for the replacement body to avoid quoting issues:

```bash
python3 - <<'PY'
import json
body = """Updated review text.

This preserves Markdown formatting and avoids shell quoting problems.
"""
with open('/tmp/pr-review-body.json', 'w') as f:
    json.dump({'body': body}, f)
PY

gh api --method PUT \
  repos/OWNER/REPO/pulls/<pr>/reviews/<review_id> \
  --input /tmp/pr-review-body.json \
  --jq '{id,body}'
```

A quoted heredoc plus `-f body="$body"` also works, but JSON `--input` is safer for Markdown containing apostrophes, backticks, `${...}`, or angle-bracket placeholders.

## Review quality checklist

- Approve only PRs that were actually reviewed and have no unresolved concerns.
- Use a comment-only review for PRs with issues unless the user explicitly asks for a different review state.
- Verify your submitted review state and body with `gh pr view <pr> --json reviews`.
- If a submitted review comment renders incorrectly, update the review body through the API instead of adding duplicate corrective comments.
- Be precise when describing findings: distinguish between observed failures, likely risks, style suggestions, and questions.
- When possible, validate claims with commands or rendered output and cite the exact behavior in the review comment.
