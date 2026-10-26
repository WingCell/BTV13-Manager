"""Create a separate, family-friendly candidate list from the current BTV list and iptv-org.

The iptv-org Brazil file is only a discovery source. A public URL or HTTP 200 does
not establish the right to retransmit a pay-TV channel, so this script adds only
Pluto TV IDs through the existing jmp2.uk resolver. The validator checks that
they actually redirect to Pluto before producing the usable list.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path


EXCLUDE = re.compile(
    r"(?i)\b(?:adult|xxx|erotic|porn|sex|south park|com o ex|dating|drag|"
    r"jovens e maes|obsessao|terror|csi|ncis|crime|criminais|policial|"
    r"filmes de luta|catfish|mtv|bet pluto|premiere|espn|sportv|discovery)\b"
)
QUALITY = re.compile(r"\s*\((?:\d{3,4}p|United States)(?:\s+BR)?\)")
PLUTO_URL = re.compile(r"^https://jmp2\.uk/plu-[a-f0-9]{24}\.m3u8$")


def entries(path: Path) -> list[tuple[str, str]]:
    lines = path.read_text(encoding="utf-8-sig").splitlines()
    if not lines or lines[0].strip() != "#EXTM3U":
        raise ValueError(f"Invalid M3U header: {path}")
    result = []
    for index, line in enumerate(lines[:-1]):
        if line.startswith("#EXTINF:"):
            next_index = index + 1
            while next_index < len(lines) and (
                not lines[next_index].strip() or
                (lines[next_index].startswith("#") and not lines[next_index].startswith("#EXTINF:"))
            ):
                next_index += 1
            if next_index >= len(lines) or lines[next_index].startswith("#EXTINF:"):
                raise ValueError(f"Missing stream URL after: {line}")
            url = lines[next_index].strip()
            if not url.startswith(("https://", "http://")):
                raise ValueError(f"Missing stream URL after: {line}")
            result.append((line, url))
    return result


def group_for(meta: str) -> str:
    source = re.search(r'group-title="([^"]*)"', meta)
    categories = (source.group(1) if source else "").lower()
    name = meta.split(",", 1)[-1].lower()
    if "documentary" in categories or any(term in name for term in ("animais", "natureza", "smithsonian")):
        return "Documentários"
    if "news" in categories:
        return "Notícias"
    if "sports" in categories:
        return "Esportes"
    if "kids" in categories or "animation" in categories:
        return "Infantil"
    if "movies" in categories:
        return "Filmes"
    if "series" in categories:
        return "Séries"
    if "music" in categories:
        return "Música"
    return "Variedades"


def new_metadata(meta: str) -> str:
    name = QUALITY.sub("", meta.split(",", 1)[-1]).strip()
    tvg_id = re.search(r'tvg-id="([^"]*)"', meta)
    tvg_logo = re.search(r'tvg-logo="([^"]*)"', meta)
    attributes = [f'tvg-id="{tvg_id.group(1)}"'] if tvg_id else []
    attributes.append(f'tvg-name="{name}"')
    if tvg_logo and tvg_logo.group(1).startswith("https://images.pluto.tv/"):
        attributes.append(f'tvg-logo="{tvg_logo.group(1)}"')
    attributes.append(f'group-title="{group_for(meta)}"')
    return f"#EXTINF:-1 {' '.join(attributes)},{name}"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", type=Path, required=True, help="The working 31-channel list")
    parser.add_argument("--source", type=Path, required=True, help="Downloaded iptv-org br.m3u")
    parser.add_argument("--output", type=Path, required=True, help="Candidate list to validate")
    args = parser.parse_args()

    selected = entries(args.base)
    seen = {url for _, url in selected}
    for meta, url in entries(args.source):
        name = meta.split(",", 1)[-1]
        if url in seen or not PLUTO_URL.fullmatch(url) or EXCLUDE.search(name):
            continue
        selected.append((new_metadata(meta), url))
        seen.add(url)
    if len(selected) > 500:
        raise ValueError(f"Too many channels: {len(selected)}")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        "#EXTM3U\n" + "".join(f"{meta}\n{url}\n" for meta, url in selected),
        encoding="utf-8",
    )
    print(f"Base: {len(entries(args.base))}; Pluto candidates: {len(selected)-len(entries(args.base))}; total: {len(selected)}")
    print(args.output)


if __name__ == "__main__":
    main()

