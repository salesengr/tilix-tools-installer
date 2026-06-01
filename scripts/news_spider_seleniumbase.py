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
import base64
import logging
import re
import sys
import time
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


# ── Shared helpers (identical logic to news_spider_playwright.py) ─────────────


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


def _setup_logging(log_path: Path) -> None:
    """File handler: DEBUG (full tracebacks, timing). Console handler: WARNING only."""
    fmt = logging.Formatter("%(asctime)s %(levelname)-8s %(message)s", datefmt="%Y-%m-%d %H:%M:%S")
    fh = logging.FileHandler(log_path, encoding="utf-8")
    fh.setLevel(logging.DEBUG)
    fh.setFormatter(fmt)
    ch = logging.StreamHandler(sys.stderr)
    ch.setLevel(logging.WARNING)
    ch.setFormatter(fmt)
    root = logging.getLogger()
    root.setLevel(logging.DEBUG)
    root.addHandler(fh)
    root.addHandler(ch)


def _slug_from_url(url: str, max_len: int = MAX_SLUG_LEN) -> str:
    """Return a sanitized filename stem from the last path segment of a URL."""
    segment = urlparse(url).path.rstrip("/").rsplit("/", 1)[-1]
    slug = re.sub(r"[^a-z0-9]+", "-", segment.lower()).strip("-")
    return slug[:max_len] if slug else "page"


def _make_labels(urls: List[str]) -> List[str]:
    """Convert a list of URLs to unique slug labels, appending -2/-3 on collision."""
    seen: Dict[str, int] = {}
    labels = []
    for url in urls:
        slug = _slug_from_url(url)
        count = seen.get(slug, 0) + 1
        seen[slug] = count
        labels.append(slug if count == 1 else f"{slug}-{count}")
    return labels


def save_capture(
    screenshot_bytes: Optional[bytes],
    pdf_bytes: Optional[bytes],
    dest_dir: Path,
    label: str,
    mhtml_bytes: Optional[bytes] = None,
) -> Dict[str, Optional[Path]]:
    """Write labelled capture files into dest_dir (the timestamped run folder).

    Files are named <label>.png, <label>.pdf, <label>.mhtml
    so all pages from a run share one flat folder and are identifiable by prefix.
    """
    result: Dict[str, Optional[Path]] = {"screenshot": None, "pdf": None, "mhtml": None}
    dest_dir.mkdir(parents=True, exist_ok=True)
    if screenshot_bytes:
        out = dest_dir / f"{label}.png"
        out.write_bytes(screenshot_bytes)
        result["screenshot"] = out
    if pdf_bytes:
        out = dest_dir / f"{label}.pdf"
        out.write_bytes(pdf_bytes)
        result["pdf"] = out
    if mhtml_bytes:
        out = dest_dir / f"{label}.mhtml"
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
    lines = [f"\nNews Spider (SeleniumBase UC) — {site_label}", sep, header, sep]
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


# ── CLI ───────────────────────────────────────────────────────────────────────


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


# ── Entry point ───────────────────────────────────────────────────────────────


def main() -> None:
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

    # ── Set up logging ────────────────────────────────────────────────────────
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
        log.debug(
            "Phase 1: raw links=%d  filtered=%d  capped=%d",
            len(all_links), len(filtered), len(story_urls),
        )

        if not story_urls:
            log.error(
                "Phase 1: no article links found (raw=%d, include=%r)",
                len(all_links), include_pattern,
            )
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

                screenshot_path = output_dir / f"{label}.png"
                sb.save_screenshot(str(screenshot_path))

                pdf_bytes: Optional[bytes] = None
                if args.output_pdf:
                    pdf_data = sb.execute_cdp_cmd(
                        "Page.printToPDF",
                        {"printBackground": True, "preferCSSPageSize": True},
                    )
                    raw = pdf_data.get("data", "")
                    pdf_bytes = base64.b64decode(raw) if raw else None

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


if __name__ == "__main__":
    main()
