---
name: playwright-py
description: Browser automation and UI testing with Playwright using the Python (sync_api) bindings. Native Python scripts using `playwright.sync_api`, server lifecycle management via `with_server.py` (can manage backend + frontend simultaneously), headless Chromium by default, reconnaissance-then-action methodology for dynamic pages. Ships bundled helpers (dev server probe, safe click/type with retries, cookie banner handler, env-driven header injection) and worked examples (login flow, broken-link scan, responsive viewport sweep). Use when testing a web app with a Python stack (Django, FastAPI, Flask), when wiring browser tests into pytest, or when backend and frontend need to be launched together. See also `/playwright-js` for JavaScript/TypeScript variant (React, Next.js, Vue frontends).
license: Complete terms in LICENSE.txt
---

# Web Application Testing

To test local web applications, write native Python Playwright scripts.

**Helper Scripts Available**:
- `scripts/with_server.py` - Manages server lifecycle (supports multiple servers)

**Always run scripts with `--help` first** to see usage. DO NOT read the source until you try running the script first and find that a customized solution is abslutely necessary. These scripts can be very large and thus pollute your context window. They exist to be called directly as black-box scripts rather than ingested into your context window.

## Decision Tree: Choosing Your Approach

```
User task → Is it static HTML?
    ├─ Yes → Read HTML file directly to identify selectors
    │         ├─ Success → Write Playwright script using selectors
    │         └─ Fails/Incomplete → Treat as dynamic (below)
    │
    └─ No (dynamic webapp) → Is the server already running?
        ├─ No → Run: python scripts/with_server.py --help
        │        Then use the helper + write simplified Playwright script
        │
        └─ Yes → Reconnaissance-then-action:
            1. Navigate and wait for networkidle
            2. Take screenshot or inspect DOM
            3. Identify selectors from rendered state
            4. Execute actions with discovered selectors
```

## Example: Using with_server.py

To start a server, run `--help` first, then use the helper:

**Single server:**
```bash
python scripts/with_server.py --server "npm run dev" --port 5173 -- python your_automation.py
```

**Multiple servers (e.g., backend + frontend):**
```bash
python scripts/with_server.py \
  --server "cd backend && python server.py" --port 3000 \
  --server "cd frontend && npm run dev" --port 5173 \
  -- python your_automation.py
```

To create an automation script, include only Playwright logic (servers are managed automatically):
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True) # Always launch chromium in headless mode
    page = browser.new_page()
    page.goto('http://localhost:5173') # Server already running and ready
    page.wait_for_load_state('networkidle') # CRITICAL: Wait for JS to execute
    # ... your automation logic
    browser.close()
```

## Reconnaissance-Then-Action Pattern

1. **Inspect rendered DOM**:
   ```python
   page.screenshot(path='/tmp/inspect.png', full_page=True)
   content = page.content()
   page.locator('button').all()
   ```

2. **Identify selectors** from inspection results

3. **Execute actions** using discovered selectors

## Common Pitfall

❌ **Don't** inspect the DOM before waiting for `networkidle` on dynamic apps
✅ **Do** wait for `page.wait_for_load_state('networkidle')` before inspection

## Best Practices

- **Use bundled scripts as black boxes** - To accomplish a task, consider whether one of the scripts available in `scripts/` can help. These scripts handle common, complex workflows reliably without cluttering the context window. Use `--help` to see usage, then invoke directly. 
- Use `sync_playwright()` for synchronous scripts
- Always close the browser when done
- Use descriptive selectors: `text=`, `role=`, CSS selectors, or IDs
- Add appropriate waits: `page.wait_for_selector()` or `page.wait_for_timeout()`

## Reference Files

- **examples/** - Examples showing common patterns:
  - `element_discovery.py` - Discovering buttons, links, and inputs on a page
  - `static_html_automation.py` - Using file:// URLs for local HTML
  - `console_logging.py` - Capturing console logs during automation
  - `login_flow.py` - Worked login example (added in this fork)
  - `broken_links.py` - Scan visible external links for broken URLs (added in this fork)
  - `responsive_sweep.py` - Screenshot multiple viewports for responsive QA (added in this fork)

---

## Added: Dev Server Detection

Before testing, see what's running on localhost. Run the bundled helper:

```bash
python scripts/detect_dev_servers.py
```

Outputs JSON: `[{"port": 5173, "url": "http://localhost:5173", "server": "vite"}, ...]`. Use this to discover the target URL rather than hardcoding it. If nothing is found, either start the server manually or use `scripts/with_server.py`.

## Added: Retry Helpers

Dynamic pages sometimes fail a click or fill on the first try. `scripts/safe_actions.py` provides retry-wrapped wrappers and a cookie-banner handler:

```python
from scripts.safe_actions import safe_click, safe_type, handle_cookie_banner

page.goto(TARGET_URL)
page.wait_for_load_state('networkidle')
handle_cookie_banner(page)   # clicks common accept buttons if present
safe_type(page, 'input[name="email"]', 'test@example.com')
safe_click(page, 'button[type="submit"]')
```

Each helper retries up to 3 times with a short delay and re-raises the last error if all attempts fail.

## Added: Env-Driven Header Injection

For authenticated testing without hardcoding tokens. Set env vars:

```bash
export PW_HEADER_NAME="Authorization"
export PW_HEADER_VALUE="Bearer eyJhbGciOi…"
# or multiple:
export PW_EXTRA_HEADERS='{"X-API-Key": "…", "X-Tenant": "acme"}'
```

Then in your script:

```python
from scripts.safe_actions import build_context_with_headers

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    context = build_context_with_headers(browser)   # auto-applies env vars
    page = context.new_page()
    ...
```

Falls back to no extra headers when env vars are unset.

## Added: Script Discipline

Write ad-hoc Playwright automation scripts to `/tmp/pw-<topic>-<date>.py`, not into the project directory. Reasons:

- OS reaps `/tmp` periodically; no stale test files to clean up
- Scripts don't clutter git status
- Keeps the project tree focused on code and not on investigation artifacts

For reusable tests that belong to the project (pytest suites, CI scripts), commit them under `tests/` as usual. One-off investigation scripts go in `/tmp`.

---

## Attribution

Forked from [anthropics/skills/skills/webapp-testing](https://github.com/anthropics/skills/tree/main/skills/webapp-testing) — Apache 2.0 licensed. See `LICENSE.txt` in this directory for the original copyright and terms.

**Local additions** (not upstream):
- `scripts/detect_dev_servers.py`, `scripts/safe_actions.py` — new helpers inspired by the sibling `playwright-js` skill (lackeyjb MIT) which bundles equivalent helpers in JavaScript.
- `examples/login_flow.py`, `examples/broken_links.py`, `examples/responsive_sweep.py` — worked examples.
- The five *Added:* sections above (Dev Server Detection, Retry Helpers, Env-Driven Header Injection, Script Discipline, and updated Reference Files list).

The upstream skill is self-contained and headless-by-default; the additions here pair the Python side with the same conveniences Craig's `playwright-js` fork has on the JavaScript side, without changing upstream semantics.