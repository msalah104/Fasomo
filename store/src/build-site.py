"""Builds the privacy pages in hosting/ from store/privacy-policy*.md.

Usage: python3 -I store/src/build-site.py   (from the project root)
"""

import re

CSS = (
    "<style>body{font:17px/1.7 -apple-system,system-ui,'Segoe UI',Tahoma,sans-serif;max-width:720px;"
    "margin:40px auto;padding:0 16px;color:#1E2A4A;background:#FFFDF8}a{color:#8A6416}h1,h2{line-height:1.3}"
    "nav{margin-bottom:24px}@media(prefers-color-scheme:dark){body{color:#F6F2E9;background:#0E1426}"
    "a{color:#E6B85C}}</style>"
)
PAGES = [
    ("store/privacy-policy.md", "hosting/privacy.html", "en", "ltr", "Fasomo privacy policy",
     '<a href="/">Home</a> · <a href="/privacy">Privacy policy</a> · <a href="/ar/privacy" lang="ar">العربية</a>'),
    ("store/privacy-policy.ar.md", "hosting/ar/privacy.html", "ar", "rtl", "سياسة الخصوصية لتطبيق فاصومو",
     '<a href="/ar/">الرئيسية</a> · <a href="/ar/privacy">سياسة الخصوصية</a> · <a href="/privacy" lang="en">English</a>'),
]


def inline(text: str) -> str:
    text = text.replace("&", "&amp;").replace("<", "&lt;")
    text = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", text)
    text = re.sub(r"\[(.+?)\]\((.+?)\)", r'<a href="\2">\1</a>', text)
    return re.sub(r"([\w.]+@[\w.]+\w)", r'<a href="mailto:\1" dir="ltr">\1</a>', text)


def body(markdown: str) -> str:
    out, in_list = [], False
    for line in markdown.split("\n"):
        if line.startswith("- "):
            if not in_list:
                out.append("<ul>")
                in_list = True
            out.append(f"<li>{inline(line[2:])}</li>")
            continue
        if in_list:
            out.append("</ul>")
            in_list = False
        if line.startswith("## "):
            out.append(f"<h2>{inline(line[3:])}</h2>")
        elif line.startswith("# "):
            out.append(f"<h1>{inline(line[2:])}</h1>")
        elif line.strip():
            out.append(f"<p>{inline(line)}</p>")
    if in_list:
        out.append("</ul>")
    return "\n".join(out)


for source, target, lang, direction, title, nav in PAGES:
    html = (
        f'<!doctype html><html lang="{lang}" dir="{direction}"><head><meta charset="utf-8">'
        f'<meta name="viewport" content="width=device-width,initial-scale=1"><title>{title}</title>{CSS}</head><body>\n'
        f"<nav>{nav}</nav>\n{body(open(source, encoding='utf-8').read())}\n</body></html>\n"
    )
    open(target, "w", encoding="utf-8").write(html)
