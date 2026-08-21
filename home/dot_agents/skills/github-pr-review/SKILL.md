---
name: github-pr-review
description: Review GitHub pull requests with the gh CLI
metadata:
  short-description: Review GitHub PRs with gh CLI
---

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
- When reporting a finding in chat, always say whether it can be posted as a GitHub inline suggestion.
- Write findings in a gentle, matter-of-fact register. State the mechanism and its consequence; do not editorialize about how bad it is.

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

## Presenting findings in chat

When you report findings, classify each one two ways: by severity, and by whether it can be posted as an inline suggestion.

Severity groups — blocking, should-fix, nit — must be honest, since users frequently ask to post only the blocking subset.

A finding maps cleanly to an inline suggestion when:

- the fix is a concrete edit to a contiguous range of lines in the diff
- the replacement text is unambiguous, not one of several reasonable designs
- applying it on its own leaves the file valid

A finding should stay prose when:

- the fix spans non-contiguous hunks (a suggestion must be one contiguous range, and multi-hunk fixes cannot be applied as a unit)
- the right shape depends on repo conventions or author intent
- it concerns the PR description, commit history, or process rather than the diff
- it is a question rather than a change

Present the mapping as a short table keyed by line number so the user can approve at a glance, and list the non-candidates separately with the reason. Then wait for explicit direction on which to post.

## Posting inline suggestions

`gh pr review` cannot attach inline comments, so build the review payload as JSON and POST it. Generate the JSON with `python3` to avoid shell quoting problems with Markdown, backticks, and `${{ ... }}`.

Get the head SHA first:

```bash
gh pr view <pr> --json headRefOid --jq .headRefOid
```

```bash
python3 - <<'PY'
import json

comment = """Short explanation of the mechanism and its consequence.

```suggestion
<replacement text for the entire line range>
```
"""

payload = {
    "commit_id": "<head sha>",
    "body": "<top-level review body>",
    "event": "COMMENT",
    "comments": [
        {
            "path": "path/to/file",
            "start_line": 92,
            "line": 93,
            "side": "RIGHT",
            "start_side": "RIGHT",
            "body": comment,
        }
    ],
}

with open("/tmp/pr-review.json", "w") as f:
    json.dump(payload, f)
PY

gh api --method POST repos/OWNER/REPO/pulls/<pr>/reviews \
  --input /tmp/pr-review.json \
  --jq '{id, state, html_url}'
```

Notes:

- The `suggestion` block replaces the whole `start_line`..`line` range, so it must repeat any unchanged lines inside that range.
- Omit `start_line` and `start_side` for a single-line comment.
- Line numbers are relative to the file at `commit_id`; use `side: RIGHT` for added or changed lines.
- Verify placement afterwards:

```bash
gh api repos/OWNER/REPO/pulls/<pr>/comments \
  --jq '.[] | [.id, .path, .start_line, .line] | @tsv'
```

## Tone

Aim for a careful colleague pointing something out, not a verdict on the author's competence. Findings are usually right on substance and wrong on delivery, so spend the effort on framing.

- Describe the mechanism and its consequence, then stop. Do not append a sentence rating how bad it is.
- Cut editorializing closers such as "that's worse than no check at all", "this is a footgun", or "this defeats the whole purpose". They carry no information and read as scolding.
- Prefer conditional framing to absolutist framing: "if someone adds a chart" rather than "the moment someone adds a chart". Same meaning, less accusatory.
- Drop intensifiers and rhetorical flourish. "Reports a green check without validating" beats "silently passes with zero validation".
- Make each point once. Restating a criticism for emphasis reads as piling on.
- Reserve bold and emphasis for technical facts a reader might skim past, never for judgment.
- Ask instead of asserting when intent is unclear: "is dropping the path filter intentional?" rather than "the path filter was removed".
- Mention what the PR does well when it is genuinely notable, kept brief and specific. Skip generic praise.
- Be precise about confidence: separate observed failures, likely risks, style preferences, and questions. Overstating certainty is itself a tone problem.

Re-read every comment body against these points before posting. Removing one judgment sentence is usually the whole edit.

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
- For every finding, state in chat whether it can be an inline suggestion, and wait for direction on which ones to post.
- Re-read each comment body for tone before posting: cut judgment sentences, soften absolutist framing, keep the mechanism.
- After the author pushes fixes, re-fetch the head SHA and diff it against the reviewed SHA to confirm the changes landed as expected before approving.
- Verify your submitted review state and body with `gh pr view <pr> --json reviews`.
- If a submitted review comment renders incorrectly, update the review body through the API instead of adding duplicate corrective comments.
- Be precise when describing findings: distinguish between observed failures, likely risks, style suggestions, and questions.
- When possible, validate claims with commands or rendered output and cite the exact behavior in the review comment.
