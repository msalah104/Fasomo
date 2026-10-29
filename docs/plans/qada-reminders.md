# Qada reminders — plan (draft)

**Status:** draft, not built. Open questions are in section 6.

Help the user pay off their make-up (Qada) days before the next Ramadan by
letting them switch on one or more kinds of reminder. Every Qada reminder
stops by itself once the balance reaches zero.

---

## 1. Reminder kinds

The user can turn on any combination of these.

| Kind | What it does | Example notification |
|---|---|---|
| **Weekly** | On the chosen weekdays, defaulting to **Monday and Thursday**. A make-up fast on those days also counts as the Sunnah fast, so it counts twice. | "Tomorrow is Thursday: a good day to make up a fast. 4 days left." |
| **Monthly** | Once a Hijri month, either on the **White Days** (13–15, again counting for both) or on a **Hijri day** the user picks. | "The White Days start tomorrow. Make up a fast? 4 days left." |
| **Before Ramadan** | A countdown at chosen points before Ramadan, e.g. **60, 30, 14 and 7 days** before (multi-select). | "Ramadan starts in 30 days and you still owe 4 make-up fasts." |
| **Suggested pace** *(later)* | Works out a weekly pace from the balance and the weeks left, e.g. 6 days owed and 20 weeks left gives "1 a week", and schedules that. Re-planned on every sync. | "To finish before Ramadan, fast 1 make-up day a week. This week's: Thursday?" |

Shared settings for every kind:
- **Time**: the evening before (default 20:00, in time to plan suhoor) or the
  morning of the day, like the existing fasting reminders.
- **Custom message**, optional, like the existing reminders.

### Rules

- **Only while something is owed.** When the balance reaches zero, no Qada
  reminder is scheduled. The sync runs after every tracker change, so pending
  ones are cancelled at once.
- **Never on a day a make-up fast isn't allowed.** Ramadan, Eid and Tashreeq
  are skipped. A day already logged as fasted is skipped too.
- **Before Ramadan only.** Weekly and monthly reminders stop on 29 Sha'ban;
  during Ramadan nothing is scheduled. After Eid they resume if days are still
  owed (for the new Ramadan, or old debt).
- **One notification per day**, as today. When a Qada reminder falls on the
  same day as a Sunnah reminder (Monday or a White Day), they are merged into
  one notification whose text says the fast counts for both.

---

## 2. Where the user sets it up

- **Progress page, Qada section**: a "Reminders" row under the balance
  ("Weekly · Mon, Thu · 20:00", or "Off"). It opens a bottom sheet with a
  switch per kind and their options. It's offered only while days are owed.
- **Reminders tab**: a "Make-up fasts" card under the fasting-type cards,
  showing the same summary and opening the same sheet. The app shell passes it
  in through a slot, so the reminders feature still doesn't import the
  tracker.
- Notification permission is asked when the first Qada reminder is turned
  on, as it is today.

```
┌ Qada reminders ─────────────────────┐
│ Weekly                         [on] │
│   M  T  W  [T]  F  S  [M]           │
│ Monthly                       [off] │
│   (•) White Days  ( ) Hijri day [ ] │
│ Before Ramadan                 [on] │
│   [60] [30] [14] [7] days before    │
│ Time: (•) Evening before 20:00      │
│       ( ) Morning of 07:00          │
└─────────────────────────────────────┘
```

---

## 3. Architecture

### The constraint that shapes it

`NotificationReconciler` reconciles **the whole pending set** with the OS. If a
second, separate sync scheduled the Qada reminders, each sync would cancel the
other one's notifications. So there must be **one sync that collects requests
from every source**.

### Shape

- **Core (`lib/core/notifications/`)**
  - `ReminderSource` interface: given `now` and the localized copy, it returns
    `List<ReminderRequest>`.
  - `SyncNotifications` (moved up from `features/reminders`) asks every
    registered source, merges same-day requests (section 1), applies the
    shared budget of 50 nearest, and reconciles once.
  - GetIt registers the sources at the composition root:
    `[FastingReminderSource, QadaReminderSource]`.
- **Reminders feature**: the existing request building becomes
  `FastingReminderSource`, with no behaviour change.
- **Tracker feature** (it owns the balance):
  - Domain: `QadaReminderSettings` with `enabled`, a sealed `QadaCadence`
    (`Weekly(weekdays)`, `Monthly.whiteDays()`, `Monthly.hijriDay(n)`),
    `beforeRamadanDays: Set<int>`, timing and an optional message. It is
    stored as JSON under its own key.
  - A pure `QadaReminderPlanner` that takes the settings, the `FastLog`, the
    `FastingCalendar` and today, and returns the dated occurrences. All the
    rules in section 1 live here and are unit-tested.
  - `QadaReminderSource` wraps the planner for the core sync.
  - `TrackerBloc` (or a small `QadaReminderBloc`) handles the settings. Any
    change to them or to the log triggers a sync.
- **Ids and payloads**: `reminderId` values such as `qada.weekly` and
  `qada.ramadan.30` keep notification ids deterministic. Payload
  `reminder/qada.weekly/2026-11-02` lets a tap open the progress page.

### Horizon

The sync looks 60 days ahead. A "60 days before Ramadan" reminder can be
further out than that; it gets scheduled by a later foreground sync once it
falls inside the window, the same rolling approach as today. If the app isn't
opened for two months, nothing new is added. That's an existing limit, and
the home-screen widget or a background fetch could address it later.

---

## 4. Phases

1. **Core sync refactor**: `ReminderSource` and the shared sync, with the
   fasting reminders moved onto it. No user-visible change; the existing
   tests must stay green.
2. **Weekly and before-Ramadan reminders**, with the settings sheet on the
   progress page and the card on the Reminders tab.
3. **Monthly** (White Days or a Hijri day).
4. **Suggested pace.**

---

## 5. Tests

- Planner: weekly on chosen weekdays only; skips Ramadan, Eid, Tashreeq and
  logged days; stops on 29 Sha'ban and resumes after Eid; before-Ramadan
  offsets land on the right dates; nothing is scheduled when the balance is
  zero; pace maths at the edges (0 weeks left, more days than weeks).
- Sync: Qada and Monday reminders on the same day become one merged
  notification; the budget is shared; turning a source off cancels only its
  notifications.
- Settings round trip and malformed JSON → `StorageReadFailed`.
- Bloc and sheet widget tests, in Arabic too.

---

## 6. Open questions

1. **Weekly default**: Monday and Thursday, or let the user pick with no
   default?
2. **Same-day merge**: merge into one notification (proposed), or always let
   the Qada text win?
3. **Before-Ramadan offsets**: a fixed set (60/30/14/7), or any number of
   days?
4. **Suggested pace**: worth doing in the first version, or later?
5. **Where to set it up**: both the progress page and the Reminders tab
   (proposed), or only one of them?
