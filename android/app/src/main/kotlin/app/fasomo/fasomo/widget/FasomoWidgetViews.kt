package app.fasomo.fasomo.widget

import android.content.Context
import android.os.Build
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import app.fasomo.fasomo.MainActivity
import app.fasomo.fasomo.R
import es.antonborri.home_widget.HomeWidgetLaunchIntent

/** Builds the widget's views for a [FasomoWidgetContent]. Holds no state. */
object FasomoWidgetViews {
  /** Below this height (dp) only the Hijri date and the next fast fit. */
  private const val FULL_MIN_HEIGHT_DP = 96f
  private const val MIN_WIDTH_DP = 110f
  private const val MIN_HEIGHT_DP = 40f

  fun build(context: Context, content: FasomoWidgetContent): RemoteViews {
    val full = fill(context, R.layout.fasomo_widget, content, showGregorian = true)
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return full
    // Android 12+ picks the largest layout that fits the widget's current size.
    val compact = fill(context, R.layout.fasomo_widget_compact, content, showGregorian = false)
    return RemoteViews(
        mapOf(
            SizeF(MIN_WIDTH_DP, MIN_HEIGHT_DP) to compact,
            SizeF(MIN_WIDTH_DP, FULL_MIN_HEIGHT_DP) to full,
        ),
    )
  }

  private fun fill(
      context: Context,
      layout: Int,
      content: FasomoWidgetContent,
      showGregorian: Boolean,
  ): RemoteViews {
    val views = RemoteViews(context.packageName, layout)
    when (content) {
      is FasomoWidgetContent.Day -> {
        views.setTextViewText(R.id.fasomo_widget_hijri, content.hijri)
        views.setTextViewText(R.id.fasomo_widget_next_fast, content.nextFast)
        views.setViewVisibility(R.id.fasomo_widget_next_fast, View.VISIBLE)
        if (showGregorian) {
          views.setTextViewText(R.id.fasomo_widget_gregorian, content.gregorian)
          views.setViewVisibility(R.id.fasomo_widget_gregorian, View.VISIBLE)
        }
        // A fasting day gets a moon-gold outline as well as its "Today:" text.
        views.setInt(
            android.R.id.background,
            "setBackgroundResource",
            if (content.isFastingDay) {
              R.drawable.fasomo_widget_background_fasting
            } else {
              R.drawable.fasomo_widget_background
            },
        )
      }
      is FasomoWidgetContent.Stale -> showMessage(context, views, content.text, showGregorian)
      FasomoWidgetContent.NotSetUp -> showMessage(context, views, "", showGregorian)
    }
    views.setOnClickPendingIntent(
        android.R.id.background,
        HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
    )
    return views
  }

  /** Shows [text] alone, or the bundled placeholder when the app gave none. */
  private fun showMessage(
      context: Context,
      views: RemoteViews,
      text: String,
      showGregorian: Boolean,
  ) {
    val message = text.ifBlank { context.getString(R.string.fasomo_widget_placeholder) }
    views.setTextViewText(R.id.fasomo_widget_hijri, message)
    views.setViewVisibility(R.id.fasomo_widget_next_fast, View.GONE)
    if (showGregorian) views.setViewVisibility(R.id.fasomo_widget_gregorian, View.GONE)
    views.setInt(
        android.R.id.background,
        "setBackgroundResource",
        R.drawable.fasomo_widget_background,
    )
  }
}
