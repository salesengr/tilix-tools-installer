#!/usr/bin/env python3
"""
News Spider (Playwright).
=========================
Fetches a news site index page, extracts article links, and captures
screenshots (and optionally PDFs) of the index and each article using
a local Chromium browser via Playwright.

Contrast with: silo-sdk-python/examples/news_spider_harvest.py
  - Harvester uses Silo's cloud-isolated browser with global egress regions
  - This script uses a locally-installed Chromium (no Silo tokens required)

Usage:
    python scripts/news_spider_playwright.py --site bbc
    python scripts/news_spider_playwright.py --site reuters --max-pages 10
    python scripts/news_spider_playwright.py --site nikkei --output-pdf
    python scripts/news_spider_playwright.py \
        --url https://apnews.com \
        --include-pattern "/article/[a-z0-9-]+"
    python scripts/news_spider_playwright.py --site bbc --dry-run

Requirements:
    playwright install chromium  (after: bash install_security_tools.sh playwright)
"""

import argparse
import asyncio
import re
import sys
from html.parser import HTMLParser
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from urllib.parse import urljoin, urlparse

SITE_PRESETS: Dict[str, Dict[str, str]] = {
    "bbc": {
        "url": "https://www.bbc.com/news",
        "include": r"/news/articles/[a-z0-9]+",
        "exclude": r"(/sport/|/weather/|/sounds/|/iplayer/|#|\?)",
    },
    "reuters": {
        "url": "https://www.reuters.com",
        "include": r"/[a-z-]+/[0-9]{4}-[0-9]{2}-[0-9]{2}/[a-z0-9-]+-\d{4}-\d{2}-\d{2}/",
        "exclude": r"(/video/|/graphics/|/pictures/|#|\?)",
    },
    "nikkei": {
        "url": "https://www.nikkei.com",
        "include": r"/article/[A-Z0-9]{20,}",
        "exclude": r"(/ranking/|/special/|/paper/|#|\?)",
    },
}

WAIT_UNTIL = "domcontentloaded"
PAGE_TIMEOUT = 30_000  # ms


class _LinkExtractor(HTMLParser):
    """Collect href attributes from <a> tags."""

    def __init__(self) -> None:
        super().__init__()
        self.links: List[str] = []

    def handle_starttag(
        self, tag: str, attrs: List[Tuple[str, Optional[str]]]
    ) -> None:
        if tag == "a":
            for name, value in attrs:
                if name == "href" and value:
                    self.links.append(value)


def extract_links_from_html(html: str, base_url: str) -> List[str]:
    """Parse HTML and return absolute URLs of all <a href> attributes."""
    parser = _LinkExtractor()
    parser.feed(html)
    return [urljoin(base_url, href) for href in parser.links]


def filter_links(
    links: List[str],
    include_pattern: str,
    exclude_pattern: Optional[str],
    base_domain: str,
) -> List[str]:
    """Apply include/exclude regex filters, restrict to same domain, deduplicate."""
    include_re = re.compile(include_pattern)
    exclude_re = re.compile(exclude_pattern) if exclude_pattern else None
    base_bare = base_domain.lstrip("www.")

    seen: set = set()
    result: List[str] = []
    for url in links:
        parsed = urlparse(url)
        link_bare = parsed.netloc.lstrip("www.")
        if base_bare not in link_bare and link_bare not in base_bare:
            continue
        if not include_re.search(url):
            continue
        if exclude_re and exclude_re.search(url):
            continue
        normalized = f"{parsed.scheme}://{parsed.netloc}{parsed.path}"
        if normalized not in seen:
            seen.add(normalized)
            result.append(normalized)
    return result


def save_capture(
    screenshot_bytes: Optional[bytes],
    pdf_bytes: Optional[bytes],
    dest_dir: Path,
    mhtml_bytes: Optional[bytes] = None,
) -> Dict[str, Optional[Path]]:
    """Write screenshot, optional PDF, and optional MHTML bytes to dest_dir."""
    result: Dict[str, Optional[Path]] = {"screenshot": None, "pdf": None, "mhtml": None}
    dest_dir.mkdir(parents=True, exist_ok=True)
    if screenshot_bytes:
        out = dest_dir / "screenshot.png"
        out.write_bytes(screenshot_bytes)
        result["screenshot"] = out
    if pdf_bytes:
        out = dest_dir / "page.pdf"
        out.write_bytes(pdf_bytes)
        result["pdf"] = out
    if mhtml_bytes:
        out = dest_dir / "page.mhtml"
        out.write_bytes(mhtml_bytes)
        result["mhtml"] = out
    return result


def print_summary(
    rows: List[Dict], output_dir: Path, site_label: str
) -> None:
    """Print a summary table to stdout and write it to output_dir/summary.txt."""
    col_url = 60
    header = f"{'#':<4}  {'Status':<7}  {'URL':<{col_url}}  Files"
    sep = "─" * (4 + 2 + 7 + 2 + col_url + 2 + 30)
    lines = [f"\nNews Spider (Playwright) — {site_label}", sep, header, sep]
    for row in rows:
        url_trunc = row["url"][:col_url]
        files_str = ", ".join(f.name for f in row["files"] if f)
        lines.append(
            f"{row['num']:<4}  {row['status']:<7}  {url_trunc:<{col_url}}  {files_str}"
        )
    lines.append(sep)
    output = "\n".join(lines)
    print(output)
    summary_path = output_dir / "summary.txt"
    summary_path.write_text(output + "\n")
    print(f"\nSummary written to: {summary_path}")


async def _capture_page(
    browser,
    url: str,
    dest_dir: Path,
    include_pdf: bool,
    include_mhtml: bool,
    semaphore: asyncio.Semaphore,
    label: str,
) -> Dict:
    """Load a page and capture screenshot + optional PDF + optional MHTML.

    Harvester equivalent: one visual task in bulk_create_and_monitor_async.
    Result dict matches the harvester version's summary_rows format.
    MHTML is captured via the Chrome DevTools Protocol (Page.captureSnapshot).
    """
    async with semaphore:
        page = await browser.new_page()
        try:
            await page.goto(url, wait_until=WAIT_UNTIL, timeout=PAGE_TIMEOUT)
            screenshot_bytes = await page.screenshot(full_page=True)
            pdf_bytes = await page.pdf(timeout=PAGE_TIMEOUT) if include_pdf else None
            if include_mhtml:
                cdp = await page.context.new_cdp_session(page)
                snapshot = await cdp.send("Page.captureSnapshot", {"format": "mhtml"})
                mhtml_bytes = snapshot["data"].encode("utf-8")
            else:
                mhtml_bytes = None
            files = save_capture(screenshot_bytes, pdf_bytes, dest_dir, mhtml_bytes)
            extracted = [v for v in files.values() if v is not None]
            names = ", ".join(f.name for f in extracted)
            print(f"  [{label}] OK — {names}")
            return {"status": "OK", "url": url, "files": extracted, "error": None}
        except Exception as e:
            print(f"  [{label}] ERROR: {e}")
            return {"status": "ERROR", "url": url, "files": [], "error": str(e)}
        finally:
            await page.close()


def build_argparser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Spider a news site and capture screenshots using Playwright",
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
                        help="Capture PDF alongside screenshot (Chromium only)")
    parser.add_argument("--output-mhtml", action="store_true",
                        help="Save MHTML snapshot of each page for offline use")
    parser.add_argument("--output-dir", default="output", metavar="DIR",
                        help="Local output directory (default: output/)")
    parser.add_argument(
        "--max-concurrent", type=int, default=3, metavar="N",
        help="Max concurrent page captures (default: 3)",
    )
    parser.add_argument("--no-headless", dest="headless", action="store_false",
                        default=True, help="Show browser window during capture")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print plan without opening any pages")
    return parser


async def main() -> None:
    parser = build_argparser()
    args = parser.parse_args()

    # ── Input validation ──────────────────────────────────────────────────────
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
    output_dir = Path(args.output_dir) / site_label

    print(f"\nNews Spider (Playwright)")
    print(f"  Site          : {site_label} ({index_url})")
    print(f"  Max pages     : {args.max_pages}")
    print(f"  Max concurrent: {args.max_concurrent}")
    print(f"  Output        : {output_dir}/")
    formats = "screenshot" + (", PDF" if args.output_pdf else "") + (", MHTML" if args.output_mhtml else "")
    print(f"  Formats       : {formats}")

    if args.dry_run:
        print("\n  Mode: DRY RUN — no browser will be opened\n")
        print(f"  Would load    : {index_url}")
        print(f"  Include       : {include_pattern!r}")
        if exclude_pattern:
            print(f"  Exclude       : {exclude_pattern!r}")
        print(f"  Would capture : up to {args.max_pages} stories + index proof shot")
        sys.exit(0)

    # ── Check playwright is installed ─────────────────────────────────────────
    try:
        from playwright.async_api import async_playwright, Browser, Page
    except ImportError:
        print(
            "ERROR: playwright not installed.\n"
            "  Run: bash install_security_tools.sh playwright && playwright install chromium",
            file=sys.stderr,
        )
        sys.exit(1)

    # ── Phase 1: Load index page + extract links ──────────────────────────────
    # Harvester equivalent: create_harvest_task("single", ...) + wait + download ZIP
    print(f"\n── Phase 1: Fetching index page ──")
    print(f"  URL: {index_url}")

    async with async_playwright() as pw:
        browser: Browser = await pw.chromium.launch(headless=args.headless)
        page: Page = await browser.new_page()

        try:
            await page.goto(index_url, wait_until=WAIT_UNTIL, timeout=PAGE_TIMEOUT)
            html = await page.content()
        except Exception as e:
            print(f"ERROR: Failed to load index page: {e}", file=sys.stderr)
            await browser.close()
            sys.exit(1)

        print("  Extracting links...")
        all_links = extract_links_from_html(html, index_url)
        filtered = filter_links(all_links, include_pattern, exclude_pattern, base_domain)
        story_urls = filtered[: args.max_pages]

        if not story_urls:
            print(
                f"ERROR: No article links found after filtering.\n"
                f"  Scanned {len(all_links)} raw links; include={include_pattern!r}\n"
                f"  Try a different --include-pattern or --site.",
                file=sys.stderr,
            )
            await browser.close()
            sys.exit(1)

        print(f"  Found {len(story_urls)} article link(s):")
        for i, url in enumerate(story_urls, 1):
            print(f"    {i}. {url}")

        # ── Phase 2: Concurrent captures ─────────────────────────────────────
        # Harvester equivalent: bulk_create_and_monitor_async(tasks, max_concurrent=5)
        n_visual = len(story_urls) + 1
        print(f"\n── Phase 2: Capturing {n_visual} pages (max {args.max_concurrent} concurrent) ──")

        semaphore = asyncio.Semaphore(args.max_concurrent)
        labels = ["index"] + [f"story-{i:02d}" for i in range(1, len(story_urls) + 1)]
        urls_list = [index_url] + story_urls
        output_dir.mkdir(parents=True, exist_ok=True)

        capture_tasks = [
            _capture_page(
                browser=browser,
                url=url,
                dest_dir=output_dir / label,
                include_pdf=args.output_pdf,
                include_mhtml=args.output_mhtml,
                semaphore=semaphore,
                label=label,
            )
            for url, label in zip(urls_list, labels)
        ]

        results = await asyncio.gather(*capture_tasks, return_exceptions=True)

        # ── Phase 3: Summary ──────────────────────────────────────────────────
        print(f"\n── Phase 3: Summary ──")
        summary_rows: List[Dict] = []
        for i, (result, label, page_url) in enumerate(
            zip(results, labels, urls_list), 1
        ):
            if isinstance(result, Exception):
                summary_rows.append(
                    {"num": i, "status": "ERROR", "url": page_url, "files": [], "error": str(result)}
                )
            else:
                summary_rows.append(
                    {
                        "num": i,
                        "status": result["status"],
                        "url": page_url,
                        "files": result["files"],
                    }
                )

        await browser.close()

    print_summary(summary_rows, output_dir, site_label)


if __name__ == "__main__":
    asyncio.run(main())
