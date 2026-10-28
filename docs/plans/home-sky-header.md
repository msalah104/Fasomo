# Home sky header — implementation plan

A live sky at the top of the Home tab. Each time the app opens, the sun (by day)
or the moon (by night) sits where it really is in the sky for the user's time and
place, and the moon shows its real phase for the current Hijri day.

Approach: **CustomPainter + `dart_suncalc`**, following the project's clean
architecture (BLoC + GetIt, injected `Clock`, typed `Result`/`Failure`).

---

## 1. What the user sees

```
┌──────────────────────────────────────────────┐
│ ·  ˙    ·        ☾          ·    ˙      ·    │  ← sky gradient + stars (night)
│      ·      .  ·  ·  ·  .        ·           │  ← faint dotted path of the body
│   .  ·                         ·  .          │
│ ▁▂▃▂▁▁▂▃▄▃▂▁▁▁▂▂▃▂▁▁▁▂▃▄▅▄▃▂▁▁▂▂▃▂▁▁▂▃▂▁▁ │  ← horizon silhouette
│ 🌅 05:58          📍 Cairo ▾         🌇 17:12 │  ← overlay widgets, not painted
│              Sunset in 2h 14m               │
└──────────────────────────────────────────────┘
```

- **Day:** the sun moves along an arc from sunrise (start edge) to sunset
  (end edge), at the top centre at solar noon.
- **Night:** the moon moves along its own arc from moonrise to moonset. Its
  crescent shape and orientation come from the real lit fraction. If the moon is
  below the horizon, only stars are shown.
- **Dawn and dusk:** the sky gradient is driven by the sun's altitude, so dawn
  colours begin around Fajr (sun ≈ −18°) and the dusk glow peaks at Maghrib
  (sunset).
- **Placement:** a full-width rounded card above `CurrentDateCard`, about 200 dp
  tall (`AspectRatio` 16:9, clamped to 160–240 dp). It scrolls with the list.

### Mapping time to position on screen

Real azimuth and altitude would look odd on a phone: in winter the sun stays low,
and at the poles it never rises. So the projection is a stylised arc fed by real
data:

- `x = progress = (now − rise) / (set − rise)` → 0 at the start edge, 1 at the
  end edge.
- `y = currentAltitude / maxAltitudeToday` → 1 at the top of the arc at solar
  noon (or at the moon's transit).
- If `rise`/`set` is `null` (the body is always up or always down at high
  latitudes), fall back to `y` from altitude only and `x` from the hour angle.

This lives in a pure function, `SkyProjection`, which makes it easy to unit-test.

---

## 2. Location

Sun and moon positions need latitude and longitude. The app has none today
(`pubspec.yaml` has `timezone` but no location package).

### Strategy: show something right away, ask only in context

| Priority | Source | When |
|---|---|---|
| 1 | **Cached location** in `SharedPreferences` (last GPS fix or a picked city) | Every launch after the first. Instant, works offline. |
| 2 | **Device GPS, coarse accuracy** via `geolocator` | Only when the user taps the "📍 Use my location" chip. Never asked at launch. |
| 3 | **Default: Makkah** (21.4225, 39.8262) | First launch, permission denied, or GPS failure. The chip reads "📍 Approximate · Set location". |
| later | **Manual city picker** (bundled list of about 300 cities, no network) | Phase 2, for users who refuse GPS. |

Privacy rules:
- Request **coarse** permission only (`ACCESS_COARSE_LOCATION`, iOS when-in-use).
  The sky doesn't need better than about 1 km.
- Round to 2 decimals (about 1.1 km) before storing it.
- Store it on the device only. It is never sent anywhere.
- Refresh the cached fix at most once a day, and only if permission is already
  granted (`getLastKnownPosition()` first, then
  `getCurrentPosition(accuracy: low, timeLimit: 10s)`).

### Platform setup

- **Android** `AndroidManifest.xml`:
  `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>`
- **iOS** `Info.plist`: `NSLocationWhenInUseUsageDescription`, in English and
  Arabic (`InfoPlist.strings`), for example "Fasomo uses your approximate
  location to show the sun and moon in your sky."
- No background location and no always permission.

### Where location code lives

Location is shared state that the reminders feature will likely want later (for
suhoor and iftar reminders), so it goes in **`lib/core/location/`**, not inside
`home`. Per the project rules, shared types belong in `core/`.

---

## 3. File layout

```
lib/
  core/
    location/
      geo_point.dart                     # value type: lat, lng, isApproximate, source
      location_repository.dart           # interface
      location_repository_impl.dart      # cache (prefs) → gateway → default
      device_location_gateway.dart       # interface + GeolocatorLocationGateway
    time/
      minute_ticker.dart                 # interface + PeriodicMinuteTicker
    error/failures.dart                  # + sealed LocationFailure

  features/home/
    domain/
      entities/
        sky_scene.dart                   # immutable snapshot the painter draws
        celestial_body_state.dart        # altitude, azimuth, rise, set, isUp
        moon_phase.dart                  # fraction, phase(0..1), isWaxing, angle
        day_phase.dart                   # enum: night, astronomicalDawn, … dusk
      services/
        sky_calculator.dart              # interface: sun(), moon(), illumination()
      usecases/
        get_sky_scene.dart               # Clock + LocationRepository + SkyCalculator
      sky_projection.dart                # pure: SkyScene → normalised (x, y) 0..1
    data/
      services/
        suncalc_sky_calculator.dart      # the only file that imports dart_suncalc
    presentation/
      bloc/
        sky_bloc.dart / sky_event.dart / sky_state.dart
      widgets/
        sky_header.dart                  # layout, Semantics, overlay labels, lifecycle
        sky_painter.dart                 # dumb painter, takes SkyScene + SkyPalette
        sky_palette.dart                 # colour stops interpolated by sun altitude
        moon_path.dart                   # builds the crescent/gibbous Path
        location_chip.dart               # "📍 Cairo" / "Set location"
```

Dependency direction stays inward. `domain/` never imports `dart_suncalc`,
`geolocator` or Flutter. `HomePage` adds `SkyHeader` above `CurrentDateCard`,
and `SkyBloc` is provided next to `HomeBloc` in `app_shell.dart`.

---

## 4. Key types (sketch)

```dart
// core/location/geo_point.dart
enum LocationSource { cached, device, manual, fallback }

final class GeoPoint extends Equatable {
  const GeoPoint({required this.latitude, required this.longitude, required this.source});
  static const makkah = GeoPoint(latitude: 21.42, longitude: 39.83, source: LocationSource.fallback);

  final double latitude;   // degrees, −90..90
  final double longitude;  // degrees, −180..180
  final LocationSource source;
  bool get isApproximate => source == LocationSource.fallback;
  ...
}

// core/error/failures.dart
sealed class LocationFailure extends Failure { const LocationFailure(); }
final class LocationPermissionDenied extends LocationFailure { final bool permanently; ... }
final class LocationServiceDisabled extends LocationFailure { ... }
final class LocationUnavailable extends LocationFailure { ... }   // timeout / no fix

// core/location/location_repository.dart
abstract interface class LocationRepository {
  /// Cached or fallback location. Never fails, never prompts.
  Future<GeoPoint> current();
  /// Asks for permission if needed, gets a coarse fix, caches it.
  Future<Result<GeoPoint, LocationFailure>> refreshFromDevice();
}

// features/home/domain/services/sky_calculator.dart
abstract interface class SkyCalculator {
  CelestialBodyState sun(DateTime utc, GeoPoint at);
  CelestialBodyState moon(DateTime utc, GeoPoint at);
  MoonPhase moonPhase(DateTime utc);
}

// features/home/domain/entities/sky_scene.dart
final class SkyScene extends Equatable {
  final DateTime now;
  final GeoPoint location;
  final CelestialBodyState sun;
  final CelestialBodyState moon;
  final MoonPhase moonPhase;
  DayPhase get dayPhase => DayPhase.fromSunAltitude(sun.altitudeDegrees);
  ...
}
```

`SkyBloc`:

| Event | Effect |
|---|---|
| `SkyStarted` | load `current()` location → emit `ready(scene)`; subscribe to `MinuteTicker` |
| `SkyTicked` | recompute the scene (cheap, pure math) → emit only if it changed |
| `SkyResumed` | from `AppLifecycleListener` in `SkyHeader`; recompute right away |
| `SkyLocationRequested` | chip tap → `refreshFromDevice()` → new scene, or keep the fallback and surface the failure (snackbar; "Open settings" if denied permanently) |

The state is `SkyState { status, scene, locationFailure? }`. The ticker
subscription is cancelled in `close()`.

---

## 5. Drawing (`SkyPainter`)

The painter is dumb. It takes `SkyScene` plus a precomputed `SkyPalette` and
`StarField`. `shouldRepaint` is a single comparison:
`old.scene != scene || old.palette != palette`. The header is wrapped in a
`RepaintBoundary`. Layers, from back to front:

1. **Sky gradient.** Three vertical stops, interpolated between keyframes by sun
   altitude: night (< −18°), astronomical, nautical and civil twilight, golden
   hour (0–6°), day (> 6°). These are `Color.lerp`s between constant palettes,
   with separate light and dark theme variants.
2. **Stars.** About 60 points from a **seeded** `Random(42)`, so they don't
   reshuffle on every repaint. They are built once in the `StarField`
   constructor, and their opacity is `nightAmount` (0 by day, 1 below −12°).
3. **Path.** A faint dotted arc for the visible body.
4. **Sun.** A disc plus a soft radial-gradient glow. The disc turns redder and
   gets a larger glow near the horizon.
5. **Moon.** A lit disc clipped by the terminator. The terminator is half an
   ellipse whose half-width is `r · |2f − 1|`, where `f` is the lit fraction. It
   bulges toward the dark side for a crescent and toward the lit side for a
   gibbous moon. The lit side is on the right while waxing, mirrored in the
   southern hemisphere. A faint earthshine fills the dark part.
6. **Horizon silhouette.** A simple `Path` of hills (optionally a minaret
   skyline), filled with a darkened sky colour.

Text and the chip are **widgets** layered over the canvas, not painted text.
That way they get accessibility, font scaling and RTL for free. A bottom scrim
keeps text contrast at 4.5:1 or better on every palette.

**Accessibility.** The canvas is wrapped in `ExcludeSemantics`. A sibling
`Semantics(label: …)` speaks, for example, "Daytime. Sun is up. Sunrise 5:58,
sunset 17:12, 2 hours 14 minutes left" or "Night. Waxing crescent moon, 23% lit."

**Motion.** v1 is static between ticks, which also satisfies reduce motion. A
later twinkle animation must check `MediaQuery.disableAnimationsOf(context)`.

**RTL.** The arc follows reading direction: rise at the start edge and set at
the end edge, so it reads like a timeline in both Arabic and English. See open
decision D2.

---

## 6. Delivery steps (one commit each)

1. **Spike: verify `dart_suncalc`.**
   - Add `dart_suncalc: ^0.2.1`.
   - Confirm field names and units: suncalc returns altitude and azimuth in
     radians, azimuth measured from south toward west, phase in 0..1 with
     0 = new and 0.5 = full. Check the `inUtc` behaviour of `getMoonTimes`.
   - Compare with NOAA's solar calculator for Makkah on 2026-03-20 and
     2026-06-21, and for a high-latitude city (Oslo, 2026-06-21).
   - The package's last release was about 5 years ago (Dart ≥ 2.13, null-safe).
     If it fails to resolve or the numbers are off, **vendor** the suncalc port
     (BSD-2, about 300 lines) into `third_party/suncalc/` behind the same
     `SkyCalculator` interface. Nothing else changes.
2. **`core/location` with no GPS yet.** `GeoPoint`, `LocationFailure`, and
   `LocationRepositoryImpl` (prefs cache → Makkah fallback), registered in
   `injection_container.dart`. Unit tests.
3. **Home domain.** `SkyScene`, `DayPhase`, `MoonPhase`, the `SkyCalculator`
   interface, `GetSkyScene`, `SkyProjection`. Pure unit tests with a fixed
   `Clock` and a fake calculator, covering noon → centre top, sunrise → start
   edge, sunset → end edge, polar day/night, and the moon below the horizon.
4. **Data adapter.** `SuncalcSkyCalculator`, plus golden-vector tests: about 6
   known (time, place) → (altitude, azimuth) pairs within ±0.5°.
5. **Presentation.** `MinuteTicker`, `SkyBloc` (`bloc_test`), `SkyPainter`,
   `SkyPalette`, `moon_path`, and `SkyHeader` inserted into `HomePage`.
   - Golden tests at dawn, noon, sunset, crescent night and full-moon night,
     each in light and dark.
   - A Semantics test.
6. **Device location.**
   - Add `geolocator: ^14.1.2`, `GeolocatorLocationGateway`, `LocationChip`,
     and the permission flow (denied / permanently denied → "Open settings").
   - Android and iOS permission strings.
   - Bloc tests with a fake gateway.
7. **Polish.**
   - New l10n keys (en/ar): `sunrise`, `sunset`, `moonrise`, `moonset`,
     `time_until_sunset`, `use_my_location`, `approximate_location`,
     `location_denied`, `open_settings`, the moon phase names (8), and the
     semantics templates.
   - Times formatted through `DateFormatter` so Arabic gets Arabic-Indic digits.
   - Update `README.md` features and roadmap.

Each step ends with the project's definition of done:
`dart format --set-exit-if-changed . && flutter analyze --fatal-infos && flutter test`.

---

## 7. Open decisions

| # | Decision | Default in this plan |
|---|---|---|
| D1 | Fallback location when there's no permission | Makkah, marked "Approximate". An alternative is to guess the city from the device time zone (`flutter_timezone`), which is more accurate with no prompt but adds a dependency and a mapping table. |
| D2 | Arc direction in RTL | Follow reading direction (rise at the start edge). The alternative is physical east-left for everyone. |
| D3 | Show "Iftar in …" in place of "Sunset in …" | Not in v1. Maghrib ≈ sunset, but calling it iftar is a religious claim, so wait for a proper prayer-times method (for example the `adhan` package) and a user setting. |
| D4 | Horizon silhouette | Plain hills in v1. A minaret skyline is a later design pass. |

## 8. Later (out of scope for v1)

- Manual city picker with a bundled offline city list.
- A fragment shader for a more realistic atmosphere behind the same `SkyScene`.
- Star twinkle and drifting clouds (respecting reduce motion).
- Tap the header for a "Today's sky" sheet: Fajr, sunrise, noon, Maghrib,
  moonrise, moon age in Hijri days.
- Suhoor and iftar reminders reusing `core/location`.
