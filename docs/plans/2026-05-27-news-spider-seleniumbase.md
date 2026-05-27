# News Spider — SeleniumBase UC Mode Implementation Plan

> **For agentic workers:** Use superpowers:subagent-driven-development to implement task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `scripts/news_spider_seleniumbase.py` — a news spider using SeleniumBase in UC (undetected-chromedriver) mode to bypass bot detection on sites that block plain headless Chromium. Specifically targets Reuters and TASS, which reject the datacenter IP `144.202.12.237` when accessed with standard Playwright.

**Why UC mode:** SeleniumBase UC mode patches ChromeDriver to remove headless fingerprints (navigator.webdriver, CDP detection, canvas fingerprint randomization). Successfully bypasses Cloudflare and similar challenges that block Reuters/TASS.

**Architecture:** Same three-phase flow as `news_spider_playwright.py`. Phase 1 loads the index with SeleniumBase and reads `driver.page_source`. Phase 2 captures pages sequentially (UC mode is not async-safe — no concurrent captures). Phase 3 produces identical output structure and `summary.txt` format.

**Key difference from Playwright version:** Sequential captures only (no asyncio concurrency) — UC mode ChromeDriver instances cannot be safely shared across threads/tasks.

---

## Contrast with Playwright Version

| Dimension | `news_spider_playwright.py` | `news_spider_seleniumbase.py` |
|-----------|----------------------------|-------------------------------|
| Bot detection bypass | None | UC mode (patches ChromeDriver) |
| Concurrency | asyncio.gather + Semaphore | Sequential only |
| Browser API | Playwright async API | SeleniumBase / Selenium WebDriver |
| MHTML capture | CDP Page.captureSnapshot | `driver.save_page_as_mhtml()` or CDP via execute_cdp_cmd |
| PDF capture | `page.pdf()` | Chrome print-to-PDF via CDP |
| Install | `bash install_security_tools.sh playwright` | `bash install_security_tools.sh seleniumbase` |
| Sites | bbc, nikkei, google-news | reuters, tass (bot-protected) |

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Create | `scripts/news_spider_seleniumbase.py` | Entire script |

No installer files are modified. SeleniumBase is already defined in `lib/data/tool-definitions.sh` under `WEB_TOOLS`.

---

## Dependencies

```bash
bash install_security_tools.sh seleniumbase
# SeleniumBase UC mode downloads its own ChromeDriver automatically
```

---

## Site Presets

```python
SITE_PRESETS = {
    "reuters": {
        "url": "https://www.reuters.com",
        "include": r"/[a-z-]+/[0-9]{4}-[0-9]{2}-[0-9]{2}/[a-z0-9-]+-\d{4}-\d{2}-\d{2}/",
        "exclude": r"(/video/|/graphics/|/pictures/|#|\?)",
    },
    "tass": {
        "url": "https://tass.ru",
        "include": r"/[a-z-]+/\d{6,}",
        "exclude": r"(/tag/|/search|/person/|/doc/|/info/|/spec/|#|\?)",
    },
}
```

---

## Constants shared with Playwright version

```python
PAGE_TIMEOUT = 30  # seconds (SeleniumBase uses seconds, not ms)
MAX_SLUG_LEN = 40
```

---

## Task 1: Scaffold — imports, constants, CLI, skeleton main()

**Files:** Create `scripts/news_spider_seleniumbase.py`

- [ ] **Step 1: Create the file**

```python
#!/usr/bin/env python3
"""
News Spider (SeleniumBase UC Mode).
====================================
Fetches a news site index page, extracts article links, and captures
screenshots of the index and each article using SeleniumBase in UC
(undetected-chromedriver) mode.

Contrast with: scripts/news_spider_playwright.py
  - Playwright: fast, async, concurrent — blocked by Cloudflare/bot detection
  - This script: UC mode bypasses bot detection — sequential captures only

Target sites: Reuters, TASS (blocked by plain headless Chromium)

Usage:
    python scripts/news_spider_seleniumbase.py --site reuters
    python scripts/news_spider_seleniumbase.py --site tass --max-pages 5
    python scripts/news_spider_seleniumbase.py --site reuters --output-pdf
    python scripts/news_spider_seleniumbase.py --site reuters --dry-run

Requirements:
    bash install_security_tools.sh seleniumbase
"""

import argparse
import logging
import re
import sys
from datetime import datetime
from html.parser import HTMLParser
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from urllib.parse import urljoin, urlparse

log = logging.getLogger(__name__)

SITE_PRESETS: Dict[str, Dict[str, str]] = {
    "reuters": {
        "url": "https://www.reuters.com",
        "include": r"/[a-z-]+/[0-9]{4}-[0-9]{2}-[0-9]{2}/[a-z0-9-]+-\d{4}-\d{2}-\d{2}/",
        "exclude": r"(/video/|/graphics/|/pictures/|#|\?)",
    },
    "tass": {
        "url": "https://tass.ru",
        "include": r"/[a-z-]+/\d{6,}",
        "exclude": r"(/tag/|/search|/person/|/doc/|/info/|/spec/|#|\?)",
    },
}

PAGE_TIMEOUT = 30  # seconds
MAX_SLUG_LEN = 40


def build_argparser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Spider bot-protected news sites using SeleniumBase UC mode",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--site", choices=list(SITE_PRESETS), help="Named news site preset")
    parser.add_argument("--url", help="Custom index URL (required if --site not used)")
    parser.add_argument("--include-pattern", help="Regex that article URLs must match")
    parser.add_argument(
        "--max-pages", type=int, default=5, metavar="N",
        help="Max story pages to capture (default: 5)",
    )
    parser.add_argument("--output-pdf", action="store_true",
                        help="Capture PDF alongside screenshot")
    parser.add_argument("--output-mhtml", action="store_true",
                        help="Save MHTML snapshot of each page for offline use")
    parser.add_argument("--output-dir", default="output", metavar="DIR",
                        help="Local output directory (default: output/)")
    parser.add_argument("--no-headless", dest="headless", action="store_false",
                        default=True, help="Show browser window during capture")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print plan without opening any pages")
    return parser


def main() -> None:
    parser = build_argparser()
    args = parser.parse_args()

    # Placeholder — phases added in later tasks
    print("scaffold ok")


if __name__ == "__main__":
    main()
```

- [ ] **Step 2: Verify CLI help works**

```bash
cd /Users/mburwick/GitHub/tilix-tools-installer
python scripts/news_spider_seleniumbase.py --help
```

- [ ] **Step 3: Commit**

```bash
git add scripts/news_spider_seleniumbase.py .claude/plans/2026-05-27-news-spider-seleniumbase.md
git commit -m "feat: add news_spider_seleniumbase scaffold with CLI and site presets"
```

---

## Task 2: Shared helpers — link extraction + output

**Files:** Modify `scripts/news_spider_seleniumbase.py`

These are identical to the Playwright version — same logic, same signatures.

- [ ] **Step 1: Add after SITE_PRESETS, before build_argparser()**

Copy verbatim from `news_spider_playwright.py`:
- `class _LinkExtractor(HTMLParser)` + `handle_starttag`
- `def extract_links_from_html(html, base_url) -> List[str]`
- `def filter_links(links, include_pattern, exclude_pattern, base_domain) -> List[str]`
- `def _slug_from_url(url, max_len=40) -> str`
- `def _make_labels(urls) -> List[str]`
- `def save_capture(screenshot_bytes, pdf_bytes, dest_dir, label, mhtml_bytes=None) -> Dict`
- `def print_summary(rows, output_dir, site_label) -> None`

- [ ] **Step 2: Verify no errors**

```bash
python scripts/news_spider_seleniumbase.py --help
```

- [ ] **Step 3: Commit**

```bash
git add scripts/news_spider_seleniumbase.py
git commit -m "feat: add shared link extraction and output helpers to news_spider_seleniumbase"
```

---

## Task 3: Logging setup

**Files:** Modify `scripts/news_spider_seleniumbase.py`

Identical to Playwright version — copy `_setup_logging()` verbatim.

- [ ] **Step 1: Add `import time` to imports and copy `_setup_logging(log_path)` before `build_argparser()`**

- [ ] **Step 2: Verify**

```bash
python scripts/news_spider_seleniumbase.py --help
```

- [ ] **Step 3: Commit**

```bash
git add scripts/news_spider_seleniumbase.py
git commit -m "feat: add logging setup to news_spider_seleniumbase"
```

---

## Task 4: main() — input validation, banner, dry-run, logging init

**Files:** Modify `scripts/news_spider_seleniumbase.py`

Replace skeleton `main()` body. Identical to Playwright version except:
- No `wait_until` / `capture_wait_until` (SeleniumBase handles waits internally)
- No `asyncio` import needed

- [ ] **Step 1: Replace main() body**

```python
def main() -> None:
    parser = build_argparser()
    args = parser.parse_args()

    if not args.site and not args.url:
        parser.error("Either --site or --url is required")
    if args.url and not args.include_pattern:
        parser.error("--include-pattern is required when using --url")

    if args.site:
        preset = SITE_PRESETS[args.site]
        index_url = preset["url"]
        include_pattern = args.include_pattern or preset["include"]
        exclude_pattern = preset["exclude"]
        site_label = args.site
    else:
        index_url = args.url
        include_pattern = args.include_pattern
        exclude_pattern = None
        site_label = urlparse(index_url).netloc

    base_domain = urlparse(index_url).netloc
    run_ts = datetime.now().strftime("%m-%d-%Y-%H-%M")
    output_dir = Path(args.output_dir) / site_label / run_ts

    formats = "screenshot" + (", PDF" if args.output_pdf else "") + (", MHTML" if args.output_mhtml else "")
    print(f"\nNews Spider (SeleniumBase UC)")
    print(f"  Site          : {site_label} ({index_url})")
    print(f"  Max pages     : {args.max_pages}")
    print(f"  Output        : {output_dir}/")
    print(f"  Formats       : {formats}")

    if args.dry_run:
        print("\n  Mode: DRY RUN — no browser will be opened\n")
        print(f"  Would load    : {index_url}")
        print(f"  Include       : {include_pattern!r}")
        if exclude_pattern:
            print(f"  Exclude       : {exclude_pattern!r}")
        print(f"  Would capture : up to {args.max_pages} stories + index proof shot")
        sys.exit(0)

    output_dir.mkdir(parents=True, exist_ok=True)
    _setup_logging(output_dir / "run.log")
    log.debug("=== news_spider_seleniumbase run ===")
    log.debug("  site         : %s", site_label)
    log.debug("  index_url    : %s", index_url)
    log.debug("  include      : %s", include_pattern)
    log.debug("  exclude      : %s", exclude_pattern)
    log.debug("  max_pages    : %d", args.max_pages)
    log.debug("  headless     : %s", args.headless)
    log.debug("  output_pdf   : %s", args.output_pdf)
    log.debug("  output_mhtml : %s", args.output_mhtml)
    log.debug("  output_dir   : %s", output_dir)

    # Phases 1-3 added in next tasks
    print("validation ok")
```

- [ ] **Step 2: Verify dry-run**

```bash
python scripts/news_spider_seleniumbase.py --site reuters --dry-run
```

- [ ] **Step 3: Commit**

```bash
git add scripts/news_spider_seleniumbase.py
git commit -m "feat: add input validation, banner, dry-run, and logging to news_spider_seleniumbase"
```

---

## Task 5: Phase 1 — index fetch via SeleniumBase UC

**Files:** Modify `scripts/news_spider_seleniumbase.py`

Key difference from Playwright: `SB(uc=True)` context manager, `sb.open(url)`, `sb.get_page_source()`.

- [ ] **Step 1: Add SeleniumBase import check + Phase 1 before `# Phases 1-3` comment**

```python
    # ── Check seleniumbase is installed ───────────────────────────────────────
    try:
        from seleniumbase import SB
    except ImportError:
        print(
            "ERROR: seleniumbase not installed.\n"
            "  Run: bash install_security_tools.sh seleniumbase",
            file=sys.stderr,
        )
        sys.exit(1)

    # ── Phase 1: Load index page + extract links ──────────────────────────────
    print(f"\n── Phase 1: Fetching index page (UC mode) ──")
    print(f"  URL: {index_url}")

    with SB(uc=True, headless=args.headless, page_load_timeout=PAGE_TIMEOUT) as sb:
        try:
            sb.open(index_url)
            # Capture Phase 1 diagnostic screenshot before link extraction
            phase1_shot = output_dir / "phase1-index.png"
            sb.save_screenshot(str(phase1_shot))
            log.debug("Phase 1: diagnostic screenshot saved to %s", phase1_shot)
            html = sb.get_page_source()
        except Exception:
            log.exception("Phase 1: failed to load index page")
            print("ERROR: Failed to load index page", file=sys.stderr)
            sys.exit(1)

        print("  Extracting links...")
        all_links = extract_links_from_html(html, index_url)
        filtered = filter_links(all_links, include_pattern, exclude_pattern, base_domain)
        story_urls = filtered[: args.max_pages]
        log.debug("Phase 1: raw links=%d  filtered=%d  capped=%d", len(all_links), len(filtered), len(story_urls))

        if not story_urls:
            log.error("Phase 1: no article links found (raw=%d, include=%r)", len(all_links), include_pattern)
            log.debug("Phase 1: sample of raw links (first 20):")
            for sample_url in all_links[:20]:
                log.debug("  %s", sample_url)
            print(
                f"ERROR: No article links found after filtering.\n"
                f"  Scanned {len(all_links)} raw links; include={include_pattern!r}\n"
                f"  Try a different --include-pattern or --site.",
                file=sys.stderr,
            )
            sys.exit(1)

        print(f"  Found {len(story_urls)} article link(s):")
        for i, url in enumerate(story_urls, 1):
            print(f"    {i}. {url}")
            log.debug("  story %d: %s", i, url)

        # Phases 2 and 3 added in next task
```

- [ ] **Step 2: Verify dry-run still works**

```bash
python scripts/news_spider_seleniumbase.py --site reuters --dry-run
```

- [ ] **Step 3: Commit**

```bash
git add scripts/news_spider_seleniumbase.py
git commit -m "feat: add Phase 1 index fetch via SeleniumBase UC to news_spider_seleniumbase"
```

---

## Task 6: Phases 2+3 — sequential captures + summary

**Files:** Modify `scripts/news_spider_seleniumbase.py`

Key difference from Playwright: sequential `for` loop replaces `asyncio.gather`. Each page opens in the existing SB session (same browser, no new instance per page).

- [ ] **Step 1: Replace `# Phases 2 and 3 added in next task` inside the `with SB(...)` block**

```python
        # ── Phase 2: Sequential captures ─────────────────────────────────────
        labels = ["index"] + _make_labels(story_urls)
        urls_list = [index_url] + story_urls
        n_visual = len(urls_list)
        print(f"\n── Phase 2: Capturing {n_visual} pages (sequential — UC mode) ──")
        log.debug("Phase 2: labels=%s", labels)

        summary_rows: List[Dict] = []
        for i, (url, label) in enumerate(zip(urls_list, labels), 1):
            log.debug("[%s] start: %s", label, url)
            t0 = time.monotonic()
            try:
                sb.open(url)
                screenshot_bytes = sb.get_element_attribute("html", "outerHTML")  # placeholder
                screenshot_path = output_dir / f"{label}.png"
                sb.save_screenshot(str(screenshot_path))

                pdf_bytes: Optional[bytes] = None
                if args.output_pdf:
                    pdf_data = sb.execute_cdp_cmd(
                        "Page.printToPDF",
                        {"printBackground": True, "preferCSSPageSize": True},
                    )
                    pdf_bytes = bytes.fromhex(pdf_data["data"]) if isinstance(pdf_data["data"], str) else pdf_data["data"]

                mhtml_bytes: Optional[bytes] = None
                if args.output_mhtml:
                    snapshot = sb.execute_cdp_cmd("Page.captureSnapshot", {"format": "mhtml"})
                    mhtml_bytes = snapshot["data"].encode("utf-8")

                # save_capture handles pdf and mhtml; screenshot already saved above
                files = save_capture(None, pdf_bytes, output_dir, label, mhtml_bytes)
                files["screenshot"] = screenshot_path

                extracted = [v for v in files.values() if v is not None]
                names = ", ".join(f.name for f in extracted)
                elapsed = time.monotonic() - t0
                log.debug("[%s] OK in %.1fs — %s", label, elapsed, names)
                for f in extracted:
                    log.debug("[%s]   wrote %s (%d bytes)", label, f.name, f.stat().st_size)
                print(f"  [{label}] OK — {names}")
                summary_rows.append({"num": i, "status": "OK", "url": url, "files": extracted, "error": None})

            except Exception as e:
                elapsed = time.monotonic() - t0
                log.exception("[%s] ERROR after %.1fs", label, elapsed)
                print(f"  [{label}] ERROR: {e}")
                summary_rows.append({"num": i, "status": "ERROR", "url": url, "files": [], "error": str(e)})

    # ── Phase 3: Summary ──────────────────────────────────────────────────────
    print(f"\n── Phase 3: Summary ──")
    ok = sum(1 for r in summary_rows if r["status"] == "OK")
    log.debug("Phase 3: complete — %d/%d OK", ok, len(summary_rows))
    log.debug("Log written to: %s", output_dir / "run.log")
    print_summary(summary_rows, output_dir, site_label)
```

- [ ] **Step 2: Verify dry-run and syntax**

```bash
python scripts/news_spider_seleniumbase.py --site reuters --dry-run
python -c "import ast; ast.parse(open('scripts/news_spider_seleniumbase.py').read()); print('syntax ok')"
```

- [ ] **Step 3: Commit**

```bash
git add scripts/news_spider_seleniumbase.py
git commit -m "feat: add Phase 2 sequential captures and Phase 3 summary to news_spider_seleniumbase"
```

---

## Task 7: Smoke test — Reuters and TASS

- [ ] **Step 1: Ensure seleniumbase is installed**

```bash
bash install_security_tools.sh seleniumbase
```

- [ ] **Step 2: Dry-run both presets**

```bash
python scripts/news_spider_seleniumbase.py --site reuters --dry-run
python scripts/news_spider_seleniumbase.py --site tass --dry-run
```

- [ ] **Step 3: Live test Reuters**

```bash
python scripts/news_spider_seleniumbase.py --site reuters --max-pages 2
```

Expected: Phase 1 loads reuters.com without Cloudflare block, extracts article links, captures screenshots. Check `run.log` and `phase1-index.png` to confirm no bot detection wall.

- [ ] **Step 4: Live test TASS**

```bash
python scripts/news_spider_seleniumbase.py --site tass --max-pages 2
```

Expected: tass.ru loads without "Forbidden" block. Check `phase1-index.png`.

- [ ] **Step 5: Final commit**

```bash
git add scripts/news_spider_seleniumbase.py
git commit -m "feat: complete news_spider_seleniumbase — UC mode spider for bot-protected sites"
```

---

## Notes

- UC mode ChromeDriver is downloaded automatically by SeleniumBase on first run
- Sequential-only captures are a hard constraint of UC mode — do not attempt to parallelize
- If a site still blocks after UC mode, the next step is Silo (`news_spider_harvest.py`) which provides clean egress IPs
- `execute_cdp_cmd` may need adjustment depending on SeleniumBase version — verify with `pip show seleniumbase`
