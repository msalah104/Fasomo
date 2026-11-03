#!/bin/sh
# Renders the app with tool/screenshots and frames seven screens per language
# into store/android/<lang>/screenshots/.
set -e
cd "$(dirname "$0")/../.."
# SKIP_RENDER=1 frames the existing build/screenshots without re-rendering the app.
[ -n "$SKIP_RENDER" ] || flutter test tool/screenshots/app_screenshots_test.dart --dart-define=SHOT_DIR=build/screenshots >/dev/null
for lang in en ar; do
  mkdir -p "store/src/raw/$lang" "store/android/$lang/screenshots"
  i=1
  for shot in home calendar ramadan progress duas reminders dark; do
    case $shot in
      dark) src="home-$lang-dark" ;;
      *) src="$shot-$lang-light" ;;
    esac
    cp "build/screenshots/$src.png" "store/src/raw/$lang/$shot.png"
    store/src/render.sh "store/src/screenshot.html?lang=$lang&shot=$shot" \
      "$PWD/store/android/$lang/screenshots/0$i-$shot.png" 1440 2560
    i=$((i + 1))
  done
done
