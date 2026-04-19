"""Worked example: scan visible external links on a page for broken URLs.

Env vars used:
  TARGET_URL (default: http://localhost:5173)

Run:
  python examples/broken_links.py
"""

import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from playwright.sync_api import sync_playwright
from scripts.safe_actions import build_context_with_headers

TARGET_URL = os.environ.get("TARGET_URL", "http://localhost:5173")


def main() -> int:
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = build_context_with_headers(browser)
        page = context.new_page()

        page.goto(TARGET_URL)
        page.wait_for_load_state("networkidle")

        # Collect unique external hrefs
        links = page.locator('a[href^="http"]').all()
        urls = sorted(
            {link.get_attribute("href") for link in links if link.get_attribute("href")}
        )

        ok, bad, err = 0, 0, 0
        for url in urls:
            try:
                resp = page.request.head(url, timeout=5000)
                status = resp.status
                if status < 400:
                    ok += 1
                    print(f"✓ {status} {url}")
                else:
                    bad += 1
                    print(f"✗ {status} {url}")
            except Exception as ex:
                err += 1
                print(f"✗ ERR {url}  ({type(ex).__name__}: {ex})")

        print(f"\n{ok} ok, {bad} broken, {err} errored out of {len(urls)} total")
        browser.close()
        return 0 if (bad == 0 and err == 0) else 1


if __name__ == "__main__":
    sys.exit(main())
