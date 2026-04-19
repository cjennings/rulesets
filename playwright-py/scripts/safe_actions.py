"""Retry-wrapped Playwright action helpers + common convenience utilities.

Usage:
    from scripts.safe_actions import (
        safe_click, safe_type, handle_cookie_banner, build_context_with_headers
    )
"""

import json
import os
import time


def safe_click(page, selector, retries: int = 3, delay: float = 0.5, timeout: int = 5000):
    """Click SELECTOR. Retry up to RETRIES times with DELAY seconds between.

    Raises the last exception if all attempts fail.
    """
    last_err = None
    for attempt in range(retries):
        try:
            page.wait_for_selector(selector, timeout=timeout)
            page.click(selector)
            return
        except Exception as err:
            last_err = err
            if attempt < retries - 1:
                time.sleep(delay)
    raise last_err  # type: ignore[misc]


def safe_type(page, selector, value: str, retries: int = 3, delay: float = 0.5, timeout: int = 5000):
    """Fill SELECTOR with VALUE. Retry on failure."""
    last_err = None
    for attempt in range(retries):
        try:
            page.wait_for_selector(selector, timeout=timeout)
            page.fill(selector, value)
            return
        except Exception as err:
            last_err = err
            if attempt < retries - 1:
                time.sleep(delay)
    raise last_err  # type: ignore[misc]


def handle_cookie_banner(page, selectors=None) -> bool:
    """Try common cookie-banner accept selectors; click the first that exists.

    Returns True if a banner was found and clicked, False otherwise.
    Does not raise on failure — many pages have no banner.
    """
    selectors = selectors or [
        "#onetrust-accept-btn-handler",
        'button[aria-label*="ccept" i]',
        'button:has-text("Accept")',
        'button:has-text("I agree")',
        'button:has-text("Got it")',
        '[data-testid="uc-accept-all-button"]',
        "#cookie-accept",
        ".cookie-accept",
    ]
    for selector in selectors:
        try:
            if page.locator(selector).count() > 0:
                page.click(selector, timeout=1000)
                return True
        except Exception:
            continue
    return False


def build_context_with_headers(browser, extra_kwargs=None):
    """Create a browser context with extra HTTP headers from env vars.

    Reads:
      PW_HEADER_NAME / PW_HEADER_VALUE   — single header
      PW_EXTRA_HEADERS='{"X-A":"1","X-B":"2"}'   — JSON object of headers

    Unset env vars → plain context with no extra headers.
    extra_kwargs, if supplied, are passed to browser.new_context().
    """
    headers: dict[str, str] = {}
    name = os.environ.get("PW_HEADER_NAME")
    value = os.environ.get("PW_HEADER_VALUE")
    if name and value:
        headers[name] = value
    extra = os.environ.get("PW_EXTRA_HEADERS")
    if extra:
        try:
            parsed = json.loads(extra)
            if isinstance(parsed, dict):
                headers.update({str(k): str(v) for k, v in parsed.items()})
        except json.JSONDecodeError:
            pass

    kwargs: dict = dict(extra_kwargs or {})
    if headers:
        kwargs["extra_http_headers"] = headers
    return browser.new_context(**kwargs)
