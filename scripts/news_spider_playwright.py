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

    # Placeholder — phases added in later tasks
    print("scaffold ok")


if __name__ == "__main__":
    asyncio.run(main())
