# Home-screen widget on iOS

The WidgetKit extension is already in the Xcode project; nothing has to be
added by hand. This note says what was set up, what Apple's side still needs,
and what to check on a device, since no CI step can build or run it.

## What is in the project

- Target **FasomoWidget** (`com.apple.product-type.app-extension`), bundle id
  `app.fasomo.fasomo.FasomoWidget`, iOS 15.0, team `J83X3QNJRW`, automatic
  signing. Sources: `ios/FasomoWidget/FasomoWidget.swift` and
  `FasomoWidgetContract.swift`; `Info.plist` declares
  `com.apple.widgetkit-extension`.
- Its configurations are based on `Flutter/Debug.xcconfig` /
  `Flutter/Release.xcconfig`, so its version is the app's
  (`FLUTTER_BUILD_NAME` / `FLUTTER_BUILD_NUMBER`), as App Store validation
  requires.
- **Runner** depends on it and embeds it through an "Embed Foundation
  Extensions" phase (PlugIns) placed *before* Flutter's "Thin Binary" script;
  after it, Xcode reports a build cycle.
- App Group `group.app.fasomo.fasomo` in both `ios/Runner/Runner.entitlements`
  and `ios/FasomoWidget/FasomoWidget.entitlements`. The Dart side calls
  `HomeWidget.setAppGroupId` with the same id
  (`HomeWidgetPluginGateway.appGroupId`).

The target was added with the `xcodeproj` Ruby gem and the project re-opens
cleanly with it, but it has not been built in Xcode yet.

## Apple Developer account

Automatic signing normally registers both bundle ids and the App Group. If it
does not, in Certificates, Identifiers & Profiles:

1. Create the App Group `group.app.fasomo.fasomo`.
2. Enable **App Groups** on `app.fasomo.fasomo` and on
   `app.fasomo.fasomo.FasomoWidget`, and select that group for both.
3. Regenerate the provisioning profiles (or let Xcode do it).

## Device checklist

- [ ] `flutter build ios` succeeds, and the archive contains
      `Runner.app/PlugIns/FasomoWidget.appex`.
- [ ] Open the app once, then add the widget (small and medium): it shows
      today's Hijri date, the Gregorian date and the next fasting day, in the
      app's language.
- [ ] Switch the app to Arabic: after returning to the home screen the widget
      is in Arabic and laid out right to left.
- [ ] Change the Hijri adjustment in Settings: the widget's date moves with it.
- [ ] On a fasting day the widget has the moon-gold outline.
- [ ] Leave the phone past midnight without opening the app: the widget shows
      the new day.
- [ ] Tap the widget while the app is open on another tab or on Settings: the
      app comes back to Home.
- [ ] Before the app has ever run, the widget asks to open Fasomo.
