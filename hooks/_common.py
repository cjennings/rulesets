"""Shared helpers for Claude Code PreToolUse confirmation hooks.

Not a hook itself — imported by sibling scripts in ~/.claude/hooks/
(installed as symlinks by `make install-hooks`). Python resolves imports
relative to the invoked script's directory, so sibling symlinks just work.

Provides:
  read_payload()      → dict parsed from stdin (empty dict on failure)
  respond_ask(...)    → emit a PreToolUse permissionDecision=ask response
  scan_attribution()  → detect AI-attribution patterns in commit/PR text

AI-attribution scanning targets structural leak patterns (trailers,
footers, robot emoji) — NOT bare mentions of 'Claude' or 'Anthropic',
which are legitimate words and would false-positive on diffs discussing
the tools themselves.
"""

import json
import re
import sys
from typing import Optional


ATTRIBUTION_PATTERNS: list[tuple[str, str]] = [
    (r"Co-Authored-By:\s*(?:Claude|Anthropic|GPT|AI\b|an? LLM)",
     "Co-Authored-By trailer crediting an AI"),
    (r"🤖",
     "robot emoji (🤖)"),
    (r"Generated (?:with|by) (?:Claude|Anthropic|AI|an? LLM)",
     "'Generated with AI' footer"),
    (r"Created (?:with|by) (?:Claude|Anthropic|AI|an? LLM)",
     "'Created with AI' footer"),
    (r"Assisted by (?:Claude|Anthropic|AI|an? LLM)",
     "'Assisted by AI' credit"),
    (r"\[\s*(?:Claude|AI|LLM)\s*(?:Code)?\s*\]",
     "[Claude] / [AI] bracketed tag"),
]


def read_payload() -> dict:
    """Parse tool-call JSON from stdin. Return {} on any parse failure."""
    try:
        return json.loads(sys.stdin.read())
    except (json.JSONDecodeError, ValueError):
        return {}


def respond_ask(reason: str, system_message: Optional[str] = None) -> None:
    """Emit a PreToolUse response asking the user to confirm.

    `reason` fills the modal body (permissionDecisionReason).
    `system_message`, if set, surfaces a secondary banner/warning to the
    user in a slot distinct from the modal.
    """
    output: dict = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": reason,
        }
    }
    if system_message:
        output["systemMessage"] = system_message
    print(json.dumps(output))


def scan_attribution(text: str) -> list[str]:
    """Return human-readable descriptions of any AI-attribution hits."""
    if not text:
        return []
    hits: list[str] = []
    for pattern, description in ATTRIBUTION_PATTERNS:
        if re.search(pattern, text, re.IGNORECASE):
            hits.append(description)
    return hits
