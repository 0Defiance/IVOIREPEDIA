#!/usr/bin/env python3
"""Precompress heavy Flutter web assets with Brotli at deploy time.

Scans a `flutter build web` output directory and writes `<name>.br` next to
every `.js`, `.wasm` and `.ttf` file, so Apache can serve the precompressed
bytes to browsers that announce `br` (see the rewrite rules in
`backend/public/.htaccess`). Les polices Inter pèsent près d'un mégaoctet et
n'étaient servies qu'en TTF brut : le brotli de déploiement les ramène à
environ un tiers. Dynamic Brotli stays off: quality 11 once per
deploy costs nothing per request.

Usage: `python tools/precompress_web.py [build_dir]` (default `app/build/web`).
Skips files whose `.br` output is already newer than the source.
"""

import shutil
import subprocess
import sys
from pathlib import Path

EXTENSIONS = (".js", ".wasm", ".ttf")
QUALITY = 11


def main() -> int:
    build_dir = Path(sys.argv[1] if len(sys.argv) > 1 else "app/build/web")
    brotli = shutil.which("brotli")
    if brotli is None:
        print("error: the `brotli` command was not found on PATH.", file=sys.stderr)
        return 1
    if not build_dir.is_dir():
        print(f"error: {build_dir} is not a directory.", file=sys.stderr)
        return 1

    total_before = total_after = 0
    for path in sorted(build_dir.rglob("*")):
        if path.suffix not in EXTENSIONS or not path.is_file():
            continue
        target = path.with_name(path.name + ".br")
        if target.exists() and target.stat().st_mtime >= path.stat().st_mtime:
            status = "fresh"
        else:
            result = subprocess.run(
                [brotli, "-q", str(QUALITY), "-c", str(path)],
                capture_output=True,
            )
            if result.returncode != 0:
                print(f"error: brotli failed on {path}.", file=sys.stderr)
                return 1
            if len(result.stdout) >= path.stat().st_size:
                # The compressed form would be larger; leave the original
                # alone instead of shipping dead weight.
                if target.exists():
                    target.unlink()
                status = "skipped (larger)"
            else:
                target.write_bytes(result.stdout)
                status = "written"
        before = path.stat().st_size
        after = target.stat().st_size if target.exists() else before
        total_before += before
        total_after += after
        print(f"{status:16} {path.name:28} {before:>9} -> {after:>9}")

    saved = 100 * (1 - total_after / total_before) if total_before else 0
    print(f"total {total_before} -> {total_after} ({saved:.1f}% smaller)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
