import SwiftUI
import WidgetKit

/// What the widget shows at one moment.
enum FasomoWidgetContent {
  /// That day's entry, already in the app's language.
  case day(FasomoWidgetContract.Day)
  /// The app's own "open the app" text, once the stored entries ran out.
  case stale(String)
  /// The app has not written a snapshot yet.
  case notSetUp
}

struct FasomoWidgetEntry: TimelineEntry {
  let date: Date
  let content: FasomoWidgetContent
  let isRightToLeft: Bool
}

/// Builds the timeline from the stored snapshot only: one entry now, then one
/// at each upcoming midnight the snapshot covers, so the widget moves on to
/// the next day without the app. The app reloads the timeline whenever it
/// publishes a new snapshot.
struct FasomoWidgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> FasomoWidgetEntry {
    FasomoWidgetEntry(date: Date(), content: .day(Self.sample), isRightToLeft: false)
  }

  func getSnapshot(in context: Context, completion: @escaping (FasomoWidgetEntry) -> Void) {
    if context.isPreview {
      completion(placeholder(in: context))
    } else {
      completion(entries(from: Date()).first ?? placeholder(in: context))
    }
  }

  func getTimeline(
    in context: Context,
    completion: @escaping (Timeline<FasomoWidgetEntry>) -> Void
  ) {
    completion(Timeline(entries: entries(from: Date()), policy: .atEnd))
  }

  private func entries(from now: Date) -> [FasomoWidgetEntry] {
    // The keys are Gregorian dates, whatever calendar the device is set to.
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .current
    guard let snapshot = FasomoWidgetContract.load() else {
      return [FasomoWidgetEntry(date: now, content: .notSetUp, isRightToLeft: false)]
    }
    var entries: [FasomoWidgetEntry] = []
    let today = calendar.startOfDay(for: now)
    // Today, then each following midnight up to the first day without an
    // entry, which shows the stale text until the app is opened again.
    for offset in 0...snapshot.days.count {
      guard let day = calendar.date(byAdding: .day, value: offset, to: today) else { break }
      let key = FasomoWidgetContract.dateKey(day, calendar: calendar)
      let content: FasomoWidgetContent =
        snapshot.days[key].map(FasomoWidgetContent.day) ?? .stale(snapshot.staleText)
      entries.append(
        FasomoWidgetEntry(
          date: offset == 0 ? now : day,
          content: content,
          isRightToLeft: snapshot.rtl
        )
      )
      if case .stale = content { break }
    }
    return entries
  }

  static let sample = FasomoWidgetContract.Day(
    hijri: FasomoWidgetStrings.sampleHijri,
    gregorian: FasomoWidgetStrings.sampleGregorian,
    nextFast: FasomoWidgetStrings.sampleNextFast,
    fastingDay: true
  )
}

/// The Hilal palette (lib/core/theme/primitives.dart).
enum FasomoWidgetColors {
  /// indigo27, the night blue.
  static let night = Color(red: 30 / 255.0, green: 42 / 255.0, blue: 74 / 255.0)
  /// gold80, the moon gold.
  static let gold = Color(red: 230 / 255.0, green: 184 / 255.0, blue: 92 / 255.0)
  /// ivory96.
  static let ivory = Color(red: 246 / 255.0, green: 242 / 255.0, blue: 233 / 255.0)
  /// slate74, for the secondary line.
  static let muted = Color(red: 169 / 255.0, green: 174 / 255.0, blue: 189 / 255.0)
}

/// The few strings the widget needs before the app has written a snapshot,
/// in the device language (the snapshot itself is in the app's language).
enum FasomoWidgetStrings {
  private static var isArabic: Bool {
    Locale.preferredLanguages.first?.hasPrefix("ar") ?? false
  }

  static var name: String { isArabic ? "التاريخ الهجري والصيام القادم" : "Hijri date and next fast" }
  static var description: String {
    isArabic ? "التاريخ الهجري لليوم ويوم صيامك القادم." : "Today's Hijri date and your next fasting day."
  }
  static var placeholder: String {
    isArabic ? "افتح فاصومو لترى التاريخ الهجري لليوم" : "Open Fasomo to see today's Hijri date"
  }
  static var sampleHijri: String { isArabic ? "13 جمادى الآخرة 1448 هـ" : "13 Jumada al-Akhirah 1448 AH" }
  static var sampleGregorian: String { isArabic ? "الاثنين، 23 نوفمبر" : "Monday, November 23" }
  static var sampleNextFast: String { isArabic ? "اليوم: الأيام البيض" : "Today: White Days" }
  static var isRightToLeft: Bool { isArabic }
}

struct FasomoWidgetView: View {
  let entry: FasomoWidgetEntry

  var body: some View {
    content
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      .environment(\.layoutDirection, isRightToLeft ? .rightToLeft : .leftToRight)
      // The `homeWidget` query item tells home_widget the app was opened from
      // the widget, so the app returns to Home.
      .widgetURL(URL(string: "fasomo://home?homeWidget"))
      .fasomoWidgetBackground(outlined: isFastingDay)
  }

  private var isRightToLeft: Bool {
    switch entry.content {
    case .notSetUp: return FasomoWidgetStrings.isRightToLeft
    default: return entry.isRightToLeft
    }
  }

  private var isFastingDay: Bool {
    if case .day(let day) = entry.content { return day.fastingDay }
    return false
  }

  @ViewBuilder
  private var content: some View {
    switch entry.content {
    case .day(let day):
      VStack(alignment: .leading, spacing: 4) {
        Text(day.hijri)
          .font(.headline)
          .foregroundColor(FasomoWidgetColors.ivory)
          .lineLimit(2)
          .minimumScaleFactor(0.7)
        Text(day.gregorian)
          .font(.caption)
          .foregroundColor(FasomoWidgetColors.muted)
          .lineLimit(1)
          .minimumScaleFactor(0.7)
        Spacer(minLength: 2)
        Text(day.nextFast)
          .font(.subheadline.weight(.semibold))
          .foregroundColor(FasomoWidgetColors.gold)
          .lineLimit(2)
          .minimumScaleFactor(0.7)
      }
    case .stale(let text):
      message(text.isEmpty ? FasomoWidgetStrings.placeholder : text)
    case .notSetUp:
      message(FasomoWidgetStrings.placeholder)
    }
  }

  private func message(_ text: String) -> some View {
    Text(text)
      .font(.subheadline)
      .foregroundColor(FasomoWidgetColors.ivory)
      .minimumScaleFactor(0.7)
  }
}

extension View {
  /// The night-blue widget background, outlined in moon gold on a fasting
  /// day. iOS 17 draws widget backgrounds through `containerBackground`.
  @ViewBuilder
  func fasomoWidgetBackground(outlined: Bool) -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      self
        .containerBackground(for: .widget) {
          ZStack {
            FasomoWidgetColors.night
            if outlined {
              ContainerRelativeShape().strokeBorder(FasomoWidgetColors.gold, lineWidth: 2)
            }
          }
        }
    } else {
      self
        .padding()
        .background(
          ZStack {
            FasomoWidgetColors.night
            if outlined {
              ContainerRelativeShape().strokeBorder(FasomoWidgetColors.gold, lineWidth: 2)
            }
          }
        )
    }
  }
}

@main
struct FasomoWidget: Widget {
  /// Must match `HomeWidgetPluginGateway.iOSKind`.
  let kind = "FasomoWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: FasomoWidgetProvider()) { entry in
      FasomoWidgetView(entry: entry)
    }
    .configurationDisplayName(FasomoWidgetStrings.name)
    .description(FasomoWidgetStrings.description)
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
