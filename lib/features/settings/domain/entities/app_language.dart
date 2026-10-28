/// The language the user picked. [system] follows the device language,
/// falling back to English when the device language is unsupported.
enum AppLanguage {
  system(null),
  english('en'),
  arabic('ar');

  new(this.languageCode);

  /// The language code to force, or `null` to follow the device.
  final String? languageCode;
}
