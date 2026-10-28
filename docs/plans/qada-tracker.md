# Qada (make-up) tracker — implementation plan

**Status:** implemented. Qada reminders are on the roadmap as a follow-up.

Keep count of the Ramadan days you missed and must make up, log each make-up
fast, and see what's left before the next Ramadan.

Approach: built **into the existing `tracker` feature**, on the same fasting
log, so a make-up fast on a Monday also counts as a fasted day for the
Monday & Thursday totals and the streak. Same conventions as the tracker:
BLoC + GetIt, injected `Clock`, typed `Result`/`Failure`, ARB strings, and
everything derived on read.

---

## 1. Rules

### What you owe

Days owed are counted **per Ramadan** (per Hijri year), from two sources:

- **Missed days marked in the calendar.** A Ramadan day up to today can be
  marked "Missed (to make up)". Marking it missed clears "fasted" on that day,
  and marking it fasted clears "missed".
- **Days owed from earlier Ramadans**, entered as a number per year, for
  Ramadans before you used the app (or when you'd rather not tick each day).
  Only years whose Ramadan has started can be chosen.

`owed(year) = missed days marked in that Ramadan + days entered for that year`

### Making up

- A **make-up fast** is a fasted day with a make-up flag. Marking a day as a
  make-up fast also marks it fasted; un-marking "fasted" clears the flag too.
- Allowed on any day up to today **except** Ramadan days (Ramadan's own fast
  can't stand in for a missed one) and the forbidden days.
- Make-up fasts pay off the **oldest Ramadan first**. The per-year split is
  derived, not stored, so entering an older debt later re-sorts it correctly.
- `remaining = max(0, total owed − make-up fasts)`.
- A make-up fast is a normal fasted day for streaks and per-type totals. The
  streak rules don't change: a missed Ramadan day already breaks the streak
  because it wasn't fasted.

### Before the next Ramadan

While days are still owed, the Qada section shows how many days are left until
the next Ramadan starts.

---

## 2. What changes in the UI

### Calendar day sheet

| Day | Actions |
|---|---|
| Ramadan day, up to today | `[✓ Fasted] [✗ Missed (to make up)]` — a two-choice segmented button, either can be cleared |
| Any other loggable day | the existing "Mark as fasted" button, plus a **Make-up fast** switch once something is owed (or the day already is one) |
| Future / forbidden | nothing (unchanged) |

### Calendar cells

The check badge becomes one badge per state, each with its own icon so it
reads without colour:

- fasted: ✓ `check_circle` (gold)
- make-up fast: ↺ `history` (gold)
- missed Ramadan day: ✗ `cancel` (danger red)

The calendar takes a `dayBadgeBuilder` from the shell instead of the
`isFasted` callback, so it still doesn't know about the tracker.

### Home progress card

One extra line when something is owed: "Make-up days left: 4".

### Progress page — new "Make-up fasts (Qada)" section

```
Make-up fasts (Qada)
┌──────────────────────────────────┐
│  4   days left to make up        │
│  Days until Ramadan: 142         │
│ ─────────────────────────────── │
│  Ramadan 1446 AH     3 of 3  ███ │
│  Ramadan 1447 AH     2 of 6  █░░ │
│ ─────────────────────────────── │
│ [↺ I made up a fast today]       │  ← when today can be one
│ [+ Add days owed]                │  ← dialog: year + count
└──────────────────────────────────┘
How it works: …
```

"Add days owed" opens a dialog with a Hijri-year dropdown (the latest started
Ramadan and 14 years before it) and a − / + counter, pre-filled with what's
already entered for that year. Setting 0 removes it.

### Unchanged

Home's today card (Ramadan days there keep the plain fasted toggle; missed is
marked from the calendar), reminders, streak rules.

---

## 3. Architecture

- **Domain**
  - `FastLog` entity: `fastedDays`, `makeUpDays` (⊆ fasted),
    `missedRamadanDays`, `extraOwed` (Hijri year → days).
  - `FastLogRules` gains `whyNotMakeUp` and `whyNotMissed`.
  - `TrackerStats.summarize(FastLog, today)` adds a `QadaSummary`
    (owed, made up, remaining, per-year split, days until Ramadan, the latest
    year that can be owed).
  - New failures: `RamadanDayNotMakeUp`, `NotARamadanDay`.
  - Repository: `setFasted` (now clears missed / make-up as above),
    `setMissedRamadan`, `setMakeUp`, `setExtraOwed`; one use case each.
- **Data**: the data source reads and writes a whole `FastLog`. The fasted days
  keep their key (`fast_log`); three new keys hold the make-up days, missed days
  and `year:count` entries.
- **Presentation**: three new `TrackerBloc` events (`ToggleRamadanMissed`,
  `ToggleMakeUp`, `SetExtraOwed`), a `RamadanDayToggle`, a `MakeUpSwitch`, the
  `QadaSection` with its dialog, and a `TrackerDayBadge`.

### Not in this change

- **Qada reminders** (Monday/Thursday nudges until the balance is zero, and a
  warning before Ramadan). They need a new reminder kind in the scheduler, so
  they're a follow-up of their own.

---

## 4. Tests

- Stats: owed per year from missed days plus entered days; oldest-first
  allocation; remaining never below zero; a make-up fast on a Monday counts
  toward Monday & Thursday and the streak; days until Ramadan before, during
  and after Ramadan.
- Rules: make-up rejected in Ramadan, on forbidden and future days; missed
  rejected outside Ramadan and in the future.
- Repository: round trip of all four keys; fasted ↔ missed clear each other;
  un-fasting clears make-up; malformed `year:count` → read failure.
- Bloc: each new event, success and failure.
- Widgets: Ramadan segmented toggle, make-up switch visibility, badges, Qada
  section and dialog.
