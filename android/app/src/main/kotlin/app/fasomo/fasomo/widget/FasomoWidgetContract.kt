package app.fasomo.fasomo.widget

import java.util.Calendar
import java.util.Locale
import org.json.JSONException
import org.json.JSONObject

/**
 * Reads the snapshot the app writes for the home-screen widget.
 *
 * Mirrors `lib/core/widget/home_widget_contract.dart` (the sole Dart owner) by hand: change both,
 * and `ios/FasomoWidget/FasomoWidgetContract.swift`, in the same commit.
 */
object FasomoWidgetContract {
  const val VERSION = 1

  /** The key home_widget stores the JSON snapshot under, in `HomeWidgetPreferences`. */
  const val STORAGE_KEY = "fasomo_widget_snapshot"

  private const val VERSION_FIELD = "v"
  private const val STALE_TEXT_FIELD = "staleText"
  private const val DAYS_FIELD = "days"
  private const val HIJRI_FIELD = "hijri"
  private const val GREGORIAN_FIELD = "gregorian"
  private const val NEXT_FAST_FIELD = "nextFast"
  private const val FASTING_DAY_FIELD = "fastingDay"

  /** The local calendar day of [day] as `yyyy-MM-dd`, the key of its entry. */
  fun dateKey(day: Calendar): String =
      String.format(
          Locale.US,
          "%04d-%02d-%02d",
          day.get(Calendar.YEAR),
          day.get(Calendar.MONTH) + 1,
          day.get(Calendar.DAY_OF_MONTH),
      )

  /** What to show on [today], given the stored [json] (null when the app never wrote one). */
  fun read(json: String?, today: Calendar): FasomoWidgetContent {
    if (json == null) return FasomoWidgetContent.NotSetUp
    return try {
      val root = JSONObject(json)
      if (root.optInt(VERSION_FIELD) != VERSION) {
        FasomoWidgetContent.NotSetUp
      } else {
        val day = root.optJSONObject(DAYS_FIELD)?.optJSONObject(dateKey(today))
        if (day == null) {
          FasomoWidgetContent.Stale(root.optString(STALE_TEXT_FIELD))
        } else {
          FasomoWidgetContent.Day(
              hijri = day.getString(HIJRI_FIELD),
              gregorian = day.getString(GREGORIAN_FIELD),
              nextFast = day.getString(NEXT_FAST_FIELD),
              isFastingDay = day.optBoolean(FASTING_DAY_FIELD),
          )
        }
      }
    } catch (e: JSONException) {
      FasomoWidgetContent.NotSetUp
    }
  }
}

/** What the widget shows. */
sealed interface FasomoWidgetContent {
  /** Today's entry, already in the app's language. */
  data class Day(
      val hijri: String,
      val gregorian: String,
      val nextFast: String,
      val isFastingDay: Boolean,
  ) : FasomoWidgetContent

  /** The stored entries ended before today; [text] asks to open the app. */
  data class Stale(val text: String) : FasomoWidgetContent

  /** The app has not written a snapshot yet. */
  object NotSetUp : FasomoWidgetContent
}
