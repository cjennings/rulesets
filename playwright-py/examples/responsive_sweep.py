"""Worked example: screenshot each viewport for responsive QA.

Env vars used:
  TARGET_URL (default: http://localhost:5173)
  OUTPUT_DIR (default: /tmp)

Run:
  python examples/responsive_sweep.py
"""

import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from playwright.sync_api import sync_playwright
from scripts.safe_actions import build_context_with_headers

TARGET_URL = os.environ.get("TARGET_URL", "http://localhost:5173")
OUTPUT_DIR = Path(os.environ.get("OUTPUT_DIR", "/tmp"))

VIEWPORTS = [
    ("desktop", 1920, 1080),
    ("laptop", 1366, 768),
    ("tablet", 768, 1024),
    ("mobile", 375, 667),
]


def main() -> int:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        for name, width, height in VIEWPORTS:
            context = build_context_with_headers(
                browser, extra_kwargs={"viewport": {"width": width, "height": height}}
            )
            page = context.new_page()
            page.goto(TARGET_URL)
            page.wait_for_load_state("networkidle")
            path = OUTPUT_DIR / f"responsive-{name}.png"
            page.screenshot(path=str(path), full_page=True)
            print(f"✓ {name:<8} ({width:>4}x{height:<4}) → {path}")
            context.close()
        browser.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
