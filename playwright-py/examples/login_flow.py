"""Worked example: log in and verify redirect.

Env vars used:
  TARGET_URL (default: http://localhost:5173)
  TEST_USER  (default: test@example.com)
  TEST_PASS  (default: password123)

Run from within the skill directory (so `scripts.safe_actions` resolves):
  python examples/login_flow.py
"""

import os
import sys
from pathlib import Path

# Make sibling scripts/ importable
sys.path.insert(0, str(Path(__file__).parent.parent))

from playwright.sync_api import sync_playwright
from scripts.safe_actions import (
    handle_cookie_banner,
    safe_click,
    safe_type,
    build_context_with_headers,
)

TARGET_URL = os.environ.get("TARGET_URL", "http://localhost:5173")
TEST_USER = os.environ.get("TEST_USER", "test@example.com")
TEST_PASS = os.environ.get("TEST_PASS", "password123")


def main() -> int:
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = build_context_with_headers(browser)
        page = context.new_page()

        page.goto(f"{TARGET_URL}/login")
        page.wait_for_load_state("networkidle")

        handle_cookie_banner(page)

        safe_type(page, 'input[name="username"], input[name="email"]', TEST_USER)
        safe_type(page, 'input[name="password"]', TEST_PASS)
        safe_click(page, 'button[type="submit"]')

        page.wait_for_url("**/dashboard", timeout=5000)
        print(f"✓ Logged in; redirected to {page.url}")

        browser.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
