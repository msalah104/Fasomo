import Foundation

/// Reads the snapshot the app writes for the home-screen widget.
///
/// Mirrors `lib/core/widget/home_widget_contract.dart` (the sole Dart owner)
/// by hand: change both, and the Android `FasomoWidgetContract.kt`, in the
/// same commit. The property names are the JSON keys.
enum FasomoWidgetContract {
  static let version = 1

  /// Shared with the app; must match both `.entitlements` files and
  /// `HomeWidgetPluginGateway.appGroupId`.
  static let appGroupId = "group.app.fasomo.fasomo"

  /// The key home_widget stores the JSON snapshot under.
  static let storageKey = "fasomo_widget_snapshot"

  struct Snapshot: Decodable {
    let v: Int
    let generatedFor: String
    let rtl: Bool
    let staleText: String
    /// Keyed by `dateKey`.
    let days: [String: Day]
  }

  struct Day: Decodable {
    let hijri: String
    let gregorian: String
    let nextFast: String
    let fastingDay: Bool
  }

  /// The stored snapshot, or nil when the app has not written one this
  /// widget can read.
  static func load() -> Snapshot? {
    guard
      let json = UserDefaults(suiteName: appGroupId)?.string(forKey: storageKey),
      let data = json.data(using: .utf8),
      let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data),
      snapshot.v == version
    else { return nil }
    return snapshot
  }

  /// The local calendar day of `date` as `yyyy-MM-dd`, the key of its entry.
  static func dateKey(_ date: Date, calendar: Calendar) -> String {
    let parts = calendar.dateComponents([.year, .month, .day], from: date)
    return String(
      format: "%04ld-%02ld-%02ld",
      locale: Locale(identifier: "en_US_POSIX"),
      parts.year ?? 0, parts.month ?? 0, parts.day ?? 0
    )
  }
}
