package app.fasomo.fasomo.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.GregorianCalendar

/**
 * The home-screen widget: today's Hijri date and the next fasting day.
 *
 * Only reads the snapshot the app last wrote and picks today's entry, so it works while the app is
 * not running. Redrawn when the app publishes, at each midnight the app scheduled through
 * home_widget, and every few hours as a fallback (see `fasomo_widget_info.xml`).
 */
class FasomoWidgetProvider : HomeWidgetProvider() {
  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    val content =
        FasomoWidgetContract.read(
            widgetData.getString(FasomoWidgetContract.STORAGE_KEY, null),
            // The keys are Gregorian dates, whatever calendar the locale uses.
            GregorianCalendar(),
        )
    val views = FasomoWidgetViews.build(context, content)
    appWidgetIds.forEach { appWidgetManager.updateAppWidget(it, views) }
  }
}
