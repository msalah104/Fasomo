"""Checks each listing field against Play's character limits.

Usage: python3 -I store/src/check-listing.py store/android/en/listing.md
"""

import re
import sys

LIMITS = {
    "App name": 30,
    "Short description": 80,
    "Full description": 4000,
    "Release notes": 500,
}


def main(path: str) -> int:
    text = open(path, encoding="utf-8").read()
    failed = False
    for heading, block in re.findall(r"^##+ ([^\n]+)\n+```text\n(.*?)\n```", text, re.M | re.S):
        field = next((name for name in LIMITS if heading.startswith(name)), None)
        if field is None:
            continue
        length = len(block)
        limit = LIMITS[field]
        status = "ok" if length <= limit else "TOO LONG"
        failed |= length > limit
        print(f"{field}: {length}/{limit} {status}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
