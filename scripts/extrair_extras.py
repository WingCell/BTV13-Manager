"""Build a second OpenTV provider without duplicating the active base channels."""

import argparse
from pathlib import Path

from filtrar_m3u import entries


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", type=Path, required=True)
    parser.add_argument("--grand", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    base_urls = {url for _, url in entries(args.base)}
    new = [(meta, url) for meta, url in entries(args.grand) if url not in base_urls]
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        "#EXTM3U\n" + "".join(f"{meta}\n{url}\n" for meta, url in new),
        encoding="utf-8",
    )
    print(f"Additional channels: {len(new)}")


if __name__ == "__main__":
    main()

