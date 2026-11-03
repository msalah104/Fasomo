# Store assets

Everything needed for the Google Play listing, one folder per language.

```
store/
  privacy-policy.md          English policy, source of hosting/privacy.html
  privacy-policy.ar.md       Arabic policy, source of hosting/ar/privacy.html
  android/en/, android/ar/
    listing.md               every text field, ready to paste (App content answers are in en/)
    icon-512.png             512 × 512, 32-bit PNG, the same in both
    feature-graphic.png      1024 × 500
    screenshots/             seven 1440 × 2560 phone screenshots, upload in file order
  src/                       sources and scripts to regenerate everything
```

## Regenerating

Run from the project root. Needs Google Chrome (rendered headless) on macOS.

```bash
# screenshots in both languages: renders the app with tool/screenshots, then frames it
store/src/make-screenshots.sh
# feature graphics
store/src/render.sh store/src/feature-graphic-en.html $PWD/store/android/en/feature-graphic.png 1024 500
store/src/render.sh store/src/feature-graphic-ar.html $PWD/store/android/ar/feature-graphic.png 1024 500
# text lengths against Play's limits
python3 -I store/src/check-listing.py store/android/en/listing.md
python3 -I store/src/check-listing.py store/android/ar/listing.md
# website privacy pages from the policies, then publish
python3 -I store/src/build-site.py
firebase deploy --only hosting
```

Recapture when a screen changes. Captions are in `store/src/screenshot.html`.
