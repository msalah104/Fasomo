/// Font family tokens for the Hilal type system.
///
/// Both families are bundled in `assets/fonts/` and declared in `pubspec.yaml`
/// under these exact names, so the app renders the same type with no network.
/// This is the only place a font family string may appear.
abstract final class AppFonts {
  /// El Messiri, for display, headline and title roles.
  static const heading = 'ElMessiri';

  /// IBM Plex Sans Arabic, for body and label roles.
  ///
  /// It draws both Arabic and Latin, so it also backs up [heading].
  static const body = 'IBMPlexSansArabic';

  /// Fallback cascade for [heading]: a bundled face, never an OS default.
  static const headingFallback = <String>[body];

  /// The OFL licence text bundled with each family, keyed by the name shown
  /// on the licence page.
  static const licenseAssets = <String, String>{
    'El Messiri': 'assets/fonts/el_messiri/OFL.txt',
    'IBM Plex Sans Arabic': 'assets/fonts/ibm_plex_sans_arabic/OFL.txt',
  };
}
