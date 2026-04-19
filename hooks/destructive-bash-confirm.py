#!/usr/bin/env python3
"""PreToolUse hook for Bash: gate destructive commands behind a modal.

Detects and asks for confirmation before:
  - git push --force / -f / --force-with-lease  (overwrites remote history)
  - git reset --hard                             (discards working-tree)
  - git clean -f                                 (deletes untracked files)
  - git branch -D                                (force-deletes branches)
  - rm -rf  (any flag combo containing both -r/-R and -f)

Each pattern emits a modal with the command, local context (current
branch, uncommitted line count, targeted paths, etc.), and a warning
banner via systemMessage. First match wins — a command with multiple
destructive patterns fires on the first detected.

Non-destructive Bash calls exit 0 silent.
"""

import re
import subprocess
import sys
from typing import Optional

from _common import read_payload, respond_ask


PROTECTED_BRANCHES = {"main", "master", "develop", "release", "prod", "production"}


def main() -> int:
    payload = read_payload()
    if payload.get("tool_name") != "Bash":
        return 0

    cmd = payload.get("tool_input", {}).get("command", "")
    detection = detect_destructive(cmd)
    if not detection:
        return 0

    kind, context = detection
    reason = format_confirmation(kind, cmd, context)
    banner = context.pop("_banner", f"DESTRUCTIVE: {kind}")

    respond_ask(reason, system_message=banner)
    return 0


def detect_destructive(cmd: str) -> Optional[tuple[str, dict]]:
    """Return (kind, context) for the first destructive pattern matched."""

    if is_force_push(cmd):
        branch = run_git(["rev-parse", "--abbrev-ref", "HEAD"]).strip()
        ctx: dict = {"branch": branch or "(detached)"}
        if branch in PROTECTED_BRANCHES:
            ctx["_banner"] = (
                f"DESTRUCTIVE: force-push to PROTECTED branch '{branch}' — "
                f"rewrites shared history."
            )
        return "git push --force", ctx

    if re.search(r"(?:^|[\s;&|()])git\s+reset\s+(?:\S+\s+)*--hard\b", cmd):
        staged = count_lines(run_git(["diff", "--cached", "--stat"]))
        unstaged = count_lines(run_git(["diff", "--stat"]))
        return "git reset --hard", {
            "staged_files": max(staged - 1, 0),
            "unstaged_files": max(unstaged - 1, 0),
        }

    if re.search(r"(?:^|[\s;&|()])git\s+clean\s+(?:\S+\s+)*-[a-zA-Z]*f", cmd):
        untracked = run_git(["ls-files", "--others", "--exclude-standard"])
        return "git clean -f", {
            "untracked_files": len(untracked.splitlines()),
        }

    if m := re.search(r"(?:^|[\s;&|()])git\s+branch\s+(?:\S+\s+)*-D\s+(\S+)", cmd):
        target = m.group(1)
        unmerged = run_git(
            ["log", f"main..{target}", "--oneline"]
        ).strip() if target else ""
        ctx = {"branch_to_delete": target}
        if unmerged:
            ctx["unmerged_commits"] = len(unmerged.splitlines())
        return "git branch -D", ctx

    rm_targets = detect_rm_rf(cmd)
    if rm_targets is not None:
        ctx = {"targets": rm_targets or ["(none parsed)"]}
        dangerous = [
            t for t in rm_targets
            if t in ("/", "~", "$HOME", ".", "..", "*")
            or t.startswith("/")
            or t.startswith("~")
        ]
        if dangerous:
            ctx["_banner"] = (
                f"DESTRUCTIVE: rm -rf targeting root/home/wildcard paths: "
                f"{', '.join(dangerous)}"
            )
        return "rm -rf", ctx

    return None


def is_force_push(cmd: str) -> bool:
    """Match `git push` with any force variant."""
    if not re.search(r"(?:^|[\s;&|()])git\s+(?:\S+\s+)*push\b", cmd):
        return False
    # Look for --force / --force-with-lease / -f as a standalone flag
    # (avoid matching -f inside a longer token that isn't a flag chain)
    return bool(
        re.search(r"(?:\s|^)--force(?:-with-lease)?\b", cmd)
        or re.search(r"(?:\s|^)-[a-zA-Z]*f[a-zA-Z]*\b", cmd[cmd.find("push"):])
    )


def detect_rm_rf(cmd: str) -> Optional[list[str]]:
    """If cmd invokes `rm` with both -r/-R and -f flags, return its targets."""
    m = re.search(r"(?:^|[\s;&|()])rm\s+(.+)$", cmd)
    if not m:
        return None

    rest = m.group(1).split()
    flag_chars = ""
    i = 0
    while i < len(rest) and rest[i].startswith("-") and rest[i] != "--":
        flag_chars += rest[i][1:]
        i += 1
    if rest[i:i+1] == ["--"]:
        i += 1

    has_r = bool(re.search(r"[rR]", flag_chars))
    has_f = "f" in flag_chars
    if not (has_r and has_f):
        return None

    return rest[i:]


def run_git(args: list) -> str:
    try:
        out = subprocess.run(
            ["git"] + args,
            capture_output=True,
            text=True,
            timeout=3,
        )
        return out.stdout
    except (subprocess.SubprocessError, OSError, FileNotFoundError):
        return ""


def count_lines(text: str) -> int:
    return len([ln for ln in text.splitlines() if ln.strip()])


def format_confirmation(kind: str, cmd: str, context: dict) -> str:
    lines = [f"Run destructive command — {kind}?", ""]
    lines.append("Command:")
    lines.append(f"  {cmd}")
    lines.append("")

    if context:
        lines.append("Context:")
        for key, val in context.items():
            lines.append(f"  {key}: {val}")
        lines.append("")

    lines.append("This operation is destructive and typically irreversible.")
    lines.append("Confirm before proceeding.")
    return "\n".join(lines)


if __name__ == "__main__":
    sys.exit(main())
