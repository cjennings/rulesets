#!/usr/bin/env python3
"""PreToolUse hook for Bash: gate `git commit` behind a confirmation modal.

Reads tool-call JSON from stdin. If the Bash command is a `git commit`,
parse the message (HEREDOC or -m forms), list staged files and diff
stats, and emit JSON with permissionDecision=ask and a formatted reason
so the user sees what will actually be committed.

For non-commit Bash calls, exit 0 with no output — default permission
rules apply.

Wire in ~/.claude/settings.json (or per-project .claude/settings.json):

    {
      "hooks": {
        "PreToolUse": [
          {
            "matcher": "Bash",
            "hooks": [
              {
                "type": "command",
                "command": "~/.claude/hooks/git-commit-confirm.py"
              }
            ]
          }
        ]
      }
    }
"""

import re
import subprocess
import sys

from _common import read_payload, respond_ask, scan_attribution


MAX_FILES_SHOWN = 25
MAX_MESSAGE_LINES = 30


def main() -> int:
    payload = read_payload()
    if payload.get("tool_name") != "Bash":
        return 0

    cmd = payload.get("tool_input", {}).get("command", "")
    if not is_git_commit(cmd):
        return 0

    message = extract_commit_message(cmd)
    staged = get_staged_files()
    stats = get_diff_stats()
    author = get_author()

    reason = format_confirmation(message, staged, stats, author)

    hits = scan_attribution(message)
    system_message = (
        f"WARNING — commit message contains AI-attribution patterns: "
        f"{'; '.join(hits)}. Policy forbids AI credit in commits."
        if hits else None
    )

    respond_ask(reason, system_message=system_message)
    return 0


def is_git_commit(cmd: str) -> bool:
    """True if the command invokes `git commit` (possibly with env/cd prefix)."""
    # Strip leading assignments and subshells; find a `git commit` word boundary
    return bool(re.search(r"(?:^|[\s;&|()])git\s+(?:-[^\s]+\s+)*commit\b", cmd))


def extract_commit_message(cmd: str) -> str:
    """Parse the commit message from either HEREDOC or -m forms."""
    # HEREDOC form:  -m "$(cat <<'EOF' ... EOF)"  or  -m "$(cat <<EOF ... EOF)"
    heredoc = re.search(
        r"<<-?\s*['\"]?(\w+)['\"]?\s*\n(.*?)\n\s*\1\b",
        cmd,
        re.DOTALL,
    )
    if heredoc:
        return heredoc.group(2).strip()

    # One or more -m flags (simple single/double quotes)
    flags = re.findall(r"-m\s+([\"'])(.*?)\1", cmd, re.DOTALL)
    if flags:
        # Multiple -m flags join with blank line (git's own behavior)
        return "\n\n".join(msg for _, msg in flags).strip()

    # --message=... form
    long_form = re.findall(r"--message[=\s]([\"'])(.*?)\1", cmd, re.DOTALL)
    if long_form:
        return "\n\n".join(msg for _, msg in long_form).strip()

    return "(commit message not parseable from command line; will be edited interactively)"


def get_staged_files() -> list[str]:
    try:
        out = subprocess.run(
            ["git", "diff", "--cached", "--name-only"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        return [line for line in out.stdout.splitlines() if line.strip()]
    except (subprocess.SubprocessError, OSError, FileNotFoundError):
        return []


def get_diff_stats() -> str:
    try:
        out = subprocess.run(
            ["git", "diff", "--cached", "--shortstat"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        return out.stdout.strip() or "(no staged changes — commit may fail)"
    except (subprocess.SubprocessError, OSError, FileNotFoundError):
        return "(could not read diff stats)"


def get_author() -> str:
    """Report the git author identity that will own the commit."""
    try:
        name = subprocess.run(
            ["git", "config", "user.name"],
            capture_output=True,
            text=True,
            timeout=3,
        ).stdout.strip()
        email = subprocess.run(
            ["git", "config", "user.email"],
            capture_output=True,
            text=True,
            timeout=3,
        ).stdout.strip()
        if name and email:
            return f"{name} <{email}>"
        return "(git user.name / user.email not configured)"
    except (subprocess.SubprocessError, OSError, FileNotFoundError):
        return "(could not read git config)"


def format_confirmation(
    message: str, files: list[str], stats: str, author: str
) -> str:
    lines = ["Create commit?", ""]

    lines.append("Author:")
    lines.append(f"  {author}")
    lines.append("")

    lines.append("Message:")
    msg_lines = message.splitlines() or ["(empty)"]
    for line in msg_lines[:MAX_MESSAGE_LINES]:
        lines.append(f"  {line}")
    if len(msg_lines) > MAX_MESSAGE_LINES:
        lines.append(f"  ... ({len(msg_lines) - MAX_MESSAGE_LINES} more lines)")
    lines.append("")

    lines.append(f"Staged files ({len(files)}):")
    for f in files[:MAX_FILES_SHOWN]:
        lines.append(f"  - {f}")
    if len(files) > MAX_FILES_SHOWN:
        lines.append(f"  ... and {len(files) - MAX_FILES_SHOWN} more")
    lines.append("")

    lines.append(f"Stats: {stats}")

    lines.append("")
    lines.append("Confirm the message, author, and file list before proceeding.")
    return "\n".join(lines)


if __name__ == "__main__":
    sys.exit(main())
