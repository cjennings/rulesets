#!/usr/bin/env python3
"""PreToolUse hook for Bash: gate `gh pr create` behind a confirmation modal.

Parses title, body, base, head, reviewers, labels, draft flag from the
`gh pr create` command and renders a modal so the user sees exactly what
will be opened.

Wire in ~/.claude/settings.json alongside git-commit-confirm.py:

    {
      "hooks": {
        "PreToolUse": [
          {
            "matcher": "Bash",
            "hooks": [
              {
                "type": "command",
                "command": "~/.claude/hooks/gh-pr-create-confirm.py"
              }
            ]
          }
        ]
      }
    }
"""

import re
import sys

from _common import read_payload, respond_ask, scan_attribution


MAX_BODY_LINES = 20


def main() -> int:
    payload = read_payload()
    if payload.get("tool_name") != "Bash":
        return 0

    cmd = payload.get("tool_input", {}).get("command", "")
    if not re.search(r"(?:^|[\s;&|()])gh\s+pr\s+create\b", cmd):
        return 0

    fields = parse_pr_create(cmd)
    reason = format_pr_confirmation(fields)

    # Scan both title and body — PRs leak attribution in either slot.
    scan_text = "\n".join(filter(None, [fields.get("title"), fields.get("body")]))
    hits = scan_attribution(scan_text)
    system_message = (
        f"WARNING — PR title/body contains AI-attribution patterns: "
        f"{'; '.join(hits)}. Policy forbids AI credit in PRs."
        if hits else None
    )

    respond_ask(reason, system_message=system_message)
    return 0


def parse_pr_create(cmd: str) -> dict:
    fields: dict = {
        "title": None,
        "body": None,
        "base": None,
        "head": None,
        "reviewers": [],
        "labels": [],
        "assignees": [],
        "milestone": None,
        "draft": False,
    }

    # Title — quoted string after --title / -t
    t = re.search(r"--title\s+([\"'])(.*?)\1", cmd, re.DOTALL)
    if not t:
        t = re.search(r"\s-t\s+([\"'])(.*?)\1", cmd, re.DOTALL)
    if t:
        fields["title"] = t.group(2)

    # Body — HEREDOC inside $() first, then plain quoted string, then --body-file
    body_heredoc = re.search(
        r"--body\s+\"\$\(cat\s*<<-?\s*['\"]?(\w+)['\"]?\s*\n(.*?)\n\s*\1\s*\)\"",
        cmd,
        re.DOTALL,
    )
    if body_heredoc:
        fields["body"] = body_heredoc.group(2).strip()
    else:
        b = re.search(r"--body\s+([\"'])(.*?)\1", cmd, re.DOTALL)
        if b:
            fields["body"] = b.group(2).strip()
        else:
            bf = re.search(r"--body-file\s+(\S+)", cmd)
            if bf:
                fields["body"] = f"(body read from file: {bf.group(1)})"

    # Base / head
    base = re.search(r"--base\s+(\S+)", cmd)
    if not base:
        base = re.search(r"\s-B\s+(\S+)", cmd)
    if base:
        fields["base"] = base.group(1)

    head = re.search(r"--head\s+(\S+)", cmd)
    if not head:
        head = re.search(r"\s-H\s+(\S+)", cmd)
    if head:
        fields["head"] = head.group(1)

    # Multi-valued flags (comma-separated or repeated)
    for name, key in (
        ("reviewer", "reviewers"),
        ("label", "labels"),
        ("assignee", "assignees"),
    ):
        pattern = rf"--{name}[=\s]([\"']?)([^\s\"']+)\1"
        for match in re.finditer(pattern, cmd):
            fields[key].extend(match.group(2).split(","))

    # Milestone
    m = re.search(r"--milestone[=\s]([\"'])?([^\s\"']+)\1?", cmd)
    if m:
        fields["milestone"] = m.group(2)

    # Draft flag
    if re.search(r"--draft\b", cmd):
        fields["draft"] = True

    return fields


def format_pr_confirmation(fields: dict) -> str:
    lines = ["Create pull request?", ""]

    if fields["draft"]:
        lines.append("[DRAFT]")
        lines.append("")

    lines.append(f"Title: {fields['title'] or '(not parsed)'}")

    base = fields["base"] or "(default — usually main)"
    head = fields["head"] or "(current branch)"
    lines.append(f"Base ← Head: {base} ← {head}")

    if fields["reviewers"]:
        lines.append(f"Reviewers: {', '.join(fields['reviewers'])}")
    if fields["assignees"]:
        lines.append(f"Assignees: {', '.join(fields['assignees'])}")
    if fields["labels"]:
        lines.append(f"Labels: {', '.join(fields['labels'])}")
    if fields["milestone"]:
        lines.append(f"Milestone: {fields['milestone']}")

    lines.append("")
    if fields["body"]:
        lines.append("Body:")
        body_lines = fields["body"].splitlines()
        for line in body_lines[:MAX_BODY_LINES]:
            lines.append(f"  {line}")
        if len(body_lines) > MAX_BODY_LINES:
            lines.append(f"  ... ({len(body_lines) - MAX_BODY_LINES} more lines)")
    else:
        lines.append("Body: (not parsed)")

    lines.append("")
    lines.append("Confirm target branch, title, body, and reviewers before proceeding.")
    return "\n".join(lines)


if __name__ == "__main__":
    sys.exit(main())
