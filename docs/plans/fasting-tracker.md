# Fasting tracker and streaks — implementation plan

**Status:** implemented.

Mark a day as fasted, from Home or from the calendar, and see your progress:
current and longest streak, and how many of this month's and this year's
fasting days you kept, per type.

Approach: a new `tracker` feature (domain / data / presentation) following the
project conventions (BLoC + GetIt, injected `Clock`, typed `Result`/`Failure`,
ARB strings). The app shell wires it into Home and Calendar, so neither of them
imports the tracker.

---

## 1. Rules

### What can be logged

- **Any day up to and including today** can be marked as fasted, so you can
  catch up on days you forgot to tick.
- **Future days** cannot be marked (you haven't fasted them yet).
- **Forbidden days** (the two Eids and Tashreeq) cannot be marked.
- An ordinary day (not a fasting day) *can* be marked: people fast voluntarily
  on other days, and the Qada tracker will build on this. It counts in the
  log but never in streaks or per-type totals.
- Unmarking is always allowed for a day that is marked.

The rules live in one pure function, `FastLogRules.whyNotLoggable(...)`, used by
both the repository (which enforces it) and the UI (which hides the button).

### Streaks

Counted over **fasting days only** (any type, including Ramadan), in date
order. A non-fasting day never extends or breaks a streak.

- A fasting day that was fasted extends the streak by one.
- A fasting day **before today** that was not fasted resets it to zero.
- **Today** never breaks the streak if it's not marked yet: the day isn't over.
- A day with several types (a White Day on a Monday) counts once.
- **Current streak** is the run that ends at the latest fasting day.
  **Longest streak** is the longest run in the whole history.

Example: Mon ✓, Thu ✓, 13th ✓, Mon ✗ → current 0, longest 3.

### Totals

For **this Hijri month** and **this Hijri year**, per fasting type:
`fasted` of `due`, where `due` counts that type's days from the start of the
period **up to today**. A day with two types counts toward both. Shown as e.g.
"White Days · 9 of 12".

Streaks and totals are **derived on read** from the set of fasted dates, never
stored, so they can't drift out of sync with the log.

### Known product trade-off

Counting the streak over *every* fasting day means someone who only fasts the
White Days will see their streak reset by each Monday and Thursday they skip.
This is what the roadmap specifies. A follow-up could let the user pick which
types count ("my fasts"), which onboarding already plans to ask about.

---

## 2. What changes in the UI

### Home

```
┌────────────────────────────────────┐
│  sky header (unchanged)            │
│  week strip (unchanged)            │
│  month bar (unchanged)             │
├────────────────────────────────────┤
│ 🌙 Your fasting                  › │  ← NEW progress card
│   4  current streak   9  longest   │
│   This month: 3 of 5 fasting days  │
├────────────────────────────────────┤
│ Upcoming Fasting Days              │
│ ┌────────────────────────────────┐ │
│ │ ● Monday & Thursday   Today    │ │
│ │ description …                  │ │
│ │ [🔔 Reminder] [✓ I fasted today]│ │  ← NEW on today's card only
│ └────────────────────────────────┘ │
│ … later cards unchanged            │
└────────────────────────────────────┘
```

- **Progress card** between the month bar and the list. Tapping it opens the
  progress page. With an empty log it shows a one-line invitation instead of
  zeros.
- **Today's card** gets a second button, "I fasted today" / "Fasted ✓"
  (filled when marked). Later cards are future days, so they don't get it.
  The two buttons sit in a `Wrap` so they stack at large text sizes.

### Calendar

- **Day cell**: a fasted day gets a small check badge in its top-end corner
  (an icon, not just a colour, so it reads without colour vision and in RTL).
- **Day sheet**: for days that can be logged, a toggle button
  "Mark as fasted" / "Fasted ✓". It updates live while the sheet is open.
  Future days show nothing; forbidden days show nothing new (they already say
  there's no fasting).

### Progress page (new, pushed from the Home card)

- Current and longest streak at the top.
- **This month** and **this year** sections: one row per fasting type that had
  days due, with its icon and colour, "fasted of due" and a thin progress bar.
- A short line explaining how streaks count, so a reset isn't a surprise.

No new tab: the bottom bar stays at four destinations.

### Unchanged

Sky header, week strip, month bar, reminders, about, splash. Reminders keep
firing whether a day was logged or not.

---

## 3. Architecture

```
lib/features/tracker/
  domain/
    entities/fast_log_summary.dart   # streaks + month/year totals + fasted set
    fast_log_rules.dart              # canLog(day, today) — pure
    tracker_stats.dart               # streaks + totals from the log — pure
    repositories/fast_log_repository.dart
    usecases/get_fast_log_summary.dart
    usecases/set_day_fasted.dart
  data/
    datasources/fast_log_local_data_source.dart  # shared_preferences
    repositories/fast_log_repository_impl.dart
  presentation/
    bloc/tracker_bloc.dart (+ event, state)
    pages/tracker_page.dart
    widgets/tracker_summary_card.dart   # the Home card
    widgets/fasted_toggle.dart          # used on Home and in the day sheet
    widgets/streak_stat.dart
```

- **Storage: `shared_preferences`, not Drift (for now).** The log is a set of
  dates stored as `yyyy-MM-dd` strings under one key. Ten years of every
  fasting day is under ~1,500 short strings, read once and held in memory, and
  every query is a set lookup. Drift would add codegen and a migration story
  for no measurable gain today. The data source is an interface, so moving to
  Drift later (e.g. when Qada adds per-entry notes) changes only `data/`.
- **Failures**: a new sealed `TrackerFailure` in `core/error/failures.dart`
  with `FutureDayNotLoggable` and `ForbiddenDayNotLoggable`; storage errors
  reuse `StorageReadFailed` / `StorageWriteFailed`.
- **Clock**: "today" always comes from the injected `Clock`. The shell's
  resume listener also refreshes the tracker, so the streak is right after
  midnight.
- **Wiring**: `TrackerBloc` is provided at the app root next to the others.
  `AppShell` passes `HomePage` an `isFasted` / `onToggleFasted` pair and the
  progress card; it wraps `CalendarPage` to pass `isFasted` and a builder for
  the sheet's toggle. Home and Calendar only see callbacks and widgets.

---

## 4. Tests

- `tracker_stats_test`: streaks across a Hijri month boundary, through
  Ramadan, past forbidden days (Eid doesn't break a streak), today unmarked
  doesn't break it, a missed past day resets it, multi-type days count once,
  non-fasting fasted days ignored; totals per type for month and year.
- `fast_log_rules_test`: future, today, past, forbidden.
- `fast_log_repository_impl_test`: round trip, rejects future and forbidden
  days, malformed data → `StorageReadFailed`, write refused →
  `StorageWriteFailed`.
- `tracker_bloc_test`: load, toggle on/off, failure paths.
- Widget: Home shows the toggle only on today's card; calendar cell shows the
  check badge.

---

## 5. Later (not in this change)

- Pick which fasting types count toward the streak.
- Qada tracker on the same log.
- Backup and restore of the log.
- Year heat-map on the progress page.
