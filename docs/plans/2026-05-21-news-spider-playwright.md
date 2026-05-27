# News Spider — Playwright Implementation (Completed)

**Status:** COMPLETE — `scripts/news_spider_playwright.py` fully implemented and smoke-tested on 2026-05-27.

**Goal:** A local-browser news spider mirroring the structure of `silo-sdk-python/examples/news_spider_harvest.py` for direct comparison. Playwright/Chromium runs locally; no Silo tokens required.

---

## Implemented Features

- Three-phase flow: index fetch → concurrent captures → summary
- `--site` presets: `bbc`, `nikkei`, `google-news` (working); `reuters` (blocked — see below)
- `--url` + `--include-pattern` for custom sites
- `--output-pdf` — PDF capture via Playwright
- `--output-mhtml` — MHTML snapshot via Chrome DevTools Protocol (`Page.captureSnapshot`)
- `--max-pages N` — cap article count (default: 5)
- `--max-concurrent N` — asyncio.Semaphore concurrency (default: 3)
- `--no-headless` — show browser window
- `--dry-run` — print plan, no browser opened
- Timestamped output folders: `output/<site>/mm-dd-yyyy-HH-MM/`
- URL slug filenames: `<slug>.png`, `<slug>.pdf`, `<slug>.mhtml` (40-char max, collision-safe)
- Phase 1 diagnostic screenshot (`phase1-index.png`) always saved before link extraction
- Raw link sample logged when `filtered=0` to aid pattern debugging
- `run.log` in every output folder: DEBUG to file, WARNING to stderr
- Per-site `wait_until` and `capture_wait_until` overrides in SITE_PRESETS

## Output Structure

```
output/<site>/mm-dd-yyyy-HH-MM/
├── index.png
├── index.pdf           (if --output-pdf)
├── index.mhtml         (if --output-mhtml)
├── <slug>.png          (one per article)
├── phase1-index.png    (diagnostic — always written)
├── summary.txt
└── run.log
```

---

## Site Smoke Test Results (2026-05-27)

| Site | Preset | Result | Notes |
|------|--------|--------|-------|
| BBC | `bbc` | ✅ PASS | 246 raw → 23 filtered, 3/3 OK, ~18s |
| Nikkei | `nikkei` | ✅ PASS | 812 raw → 67 filtered, 3/3 OK, ~18s |
| Google News | `google-news` | ✅ PASS | 131 raw → 35 filtered, 3/3 OK, ~7s; captures show redirect interstitial |
| Reuters | `reuters` | ❌ BLOCKED | Cloudflare bot detection — IP 144.202.12.237 flagged; raw links=0 |
| TASS | *(removed)* | ❌ BLOCKED | Hard block ("Forbidden") — datacenter IP flagged |

### Known Limitations

**Reuters and TASS** block headless Chromium from datacenter IPs. Plain Playwright cannot bypass this. Two remediation paths:

1. **SeleniumBase UC mode** — patches Chromium to evade bot fingerprinting (see `news_spider_seleniumbase.py` plan)
2. **Silo harvester** — route through Silo's egress infrastructure (`news_spider_harvest.py` already handles this)

---

## Architecture Notes

### Per-site `wait_until` overrides

`WAIT_UNTIL = "domcontentloaded"` is the global default. Sites that render links via JS need `"networkidle"` on the index fetch. Sites whose article pages have endless background JS need a separate `"capture_wait_until"` to prevent 30s timeouts.

```python
"google-news": {
    "wait_until": "networkidle",         # index page — wait for JS to render links
    "capture_wait_until": "domcontentloaded",  # article pages — avoid timeout on redirect
}
```

### URL slug labelling

Last path segment of each article URL, lowercased, non-alphanumeric → `-`, max 40 chars. Collisions get `-2`/`-3` suffix. Index page always labelled `index`.

### MHTML capture

Uses CDP `Page.captureSnapshot` — same mechanism Playwright uses internally. Returns MHTML string, encoded to UTF-8 bytes.

---

## Related Plans

- `2026-05-27-news-spider-seleniumbase.md` — UC mode spider for bot-protected sites (Reuters, TASS)
