"""Server-side truth card rendering (§14.7).

Renders a 1080×1920 PNG from the analysis (verdict + top damage stat + fixed
tagline) and stores it in Firebase Storage — or on local disk (served from
/static) when Storage isn't configured, so the full share flow works offline.
The mobile "capture flash" (§7.7) is presentational only; this is the real asset.
"""
from __future__ import annotations

import io
import logging
import textwrap
from pathlib import Path

from app.core.config import get_settings
from app.integrations.firebase_admin_client import get_firebase_client

logger = logging.getLogger("oracle.media.truthcard")

_W, _H = 1080, 1920
_TAGLINE = "You broke the chain. It ends with you."

_PALETTE = {
    "bg": "#0D0B1A",
    "surface": "#201C3B",
    "gold": "#FFC857",
    "false": "#E24B4A",
    "misleading": "#EF9F27",
    "true": "#1D9E75",
    "unverified": "#6E698F",
    "text": "#F5F3FF",
    "muted": "#A9A3C9",
    "border": "#3D386B",
}
_VERDICT_LABEL = {
    "false": "False",
    "misleading": "Misleading",
    "true": "True",
    "unverified": "Unverified",
}


def _rgb(hex_color: str) -> tuple[int, int, int]:
    h = hex_color.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))


def _font(size: int):
    from PIL import ImageFont

    fonts_dir = Path(__file__).resolve().parent.parent / "assets" / "fonts"
    candidates = [
        str(fonts_dir / "SpaceGrotesk-Medium.ttf"),
        "SpaceGrotesk-Medium.ttf",
        "DejaVuSans.ttf",
        "Arial.ttf",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, size)
        except Exception:
            continue
    return ImageFont.load_default()


def render_png(analysis: dict) -> bytes:
    from PIL import Image, ImageDraw

    image = Image.new("RGB", (_W, _H), _rgb(_PALETTE["bg"]))
    draw = ImageDraw.Draw(image)
    verdict = analysis.get("verdict", "unverified")
    margin = 96

    # Wordmark
    muted = _rgb(_PALETTE["muted"])
    draw.text((margin, 120), "ORACLE", font=_font(56), fill=_rgb(_PALETTE["gold"]))
    draw.text((margin, 196), "Tracing the truth through time", font=_font(30), fill=muted)

    # Verdict badge (pill)
    badge_color = _rgb(_PALETTE.get(verdict, _PALETTE["unverified"]))
    label = _VERDICT_LABEL.get(verdict, "Unverified")
    badge_font = _font(46)
    text_w = draw.textlength(label, font=badge_font)
    draw.rounded_rectangle(
        [margin, 360, margin + int(text_w) + 96, 452], radius=46, fill=badge_color
    )
    draw.text((margin + 48, 378), label, font=badge_font, fill=_rgb(_PALETTE["bg"]))

    # Claim text (wrapped, truncated)
    claim_text = _claim_summary(analysis)
    y = 540
    for line in textwrap.wrap(claim_text, width=34)[:6]:
        draw.text((margin, y), line, font=_font(52), fill=_rgb(_PALETTE["text"]))
        y += 74

    # Origin + damage one-liner
    summary = _impact_summary(analysis)
    if summary:
        draw.rounded_rectangle(
            [margin, y + 40, _W - margin, y + 220], radius=24,
            fill=_rgb(_PALETTE["surface"]), outline=_rgb(_PALETTE["border"]), width=1,
        )
        for i, line in enumerate(textwrap.wrap(summary, width=40)[:3]):
            draw.text((margin + 40, y + 72 + i * 48), line, font=_font(34), fill=muted)

    # Tagline near the bottom
    draw.text((margin, _H - 260), _TAGLINE, font=_font(44), fill=_rgb(_PALETTE["gold"]))
    draw.text((margin, _H - 150), "oracle-app.web", font=_font(30), fill=muted)

    buffer = io.BytesIO()
    image.save(buffer, format="PNG")
    return buffer.getvalue()


def _claim_summary(analysis: dict) -> str:
    origin = analysis.get("origin")
    if origin:
        places = analysis_country_count(analysis)
        return f"This claim was born on {origin['platform']} and traced across {places} places."
    if analysis.get("verdict") == "unverified":
        return "We haven't traced this one yet — but we've logged it for review."
    return "A verdict for this claim, cross-referenced from public fact-checks."


def analysis_country_count(analysis: dict) -> int:
    countries = set()
    origin = analysis.get("origin")
    if origin:
        countries.add(origin.get("country"))
    for mutation in analysis.get("mutations", []):
        countries.add(mutation.get("country"))
    return max(len(countries), 1)


def _impact_summary(analysis: dict) -> str | None:
    damage = analysis.get("damage") or []
    if not damage:
        return None
    top = max(damage, key=lambda d: d.get("value", 0))
    value = top.get("value", 0)
    formatted = f"{int(value):,}" if float(value).is_integer() else str(value)
    return f"{top.get('label')}: {formatted} — {top.get('source_name')}"


def store_truth_card(analysis_id: str, png_bytes: bytes) -> str:
    """Upload to Firebase Storage, or persist locally and return a /static URL."""
    remote_url = get_firebase_client().upload_bytes(
        f"truthcards/{analysis_id}.png", png_bytes, "image/png"
    )
    if remote_url:
        return remote_url

    settings = get_settings()
    directory = Path(settings.local_storage_dir) / "truthcards"
    directory.mkdir(parents=True, exist_ok=True)
    (directory / f"{analysis_id}.png").write_bytes(png_bytes)
    return f"{settings.public_base_url}/static/truthcards/{analysis_id}.png"
