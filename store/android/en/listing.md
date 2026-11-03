# Google Play listing: English (en-US)

Copy each block into Play Console as it is. Character counts are checked by
`store/src/check-listing.py`; Play's limits are in brackets.

## Main store listing

### App name [30]

```text
Fasomo: Sunnah Fasting Days
```

### Short description [80]

```text
Sunnah and Ramadan fasting days on the Hijri calendar, with reminders and Qada.
```

### Full description [4000]

```text
Fasomo helps you keep the recommended (Sunnah) and obligatory fasts of the Hijri year. It reminds you before each one and keeps track of what you've fasted and what you still owe.

The fasting days
• White Days: the 13th, 14th and 15th of every Hijri month
• Monday and Thursday, every week
• The Day of Arafah (9 Dhul Hijjah)
• Tasua and Ashura (9 and 10 Muharram)
• The Six Days of Shawwal
• Ramadan
Fasting is never suggested on the Eids or the days of Tashreeq. Dates follow the Umm al-Qura calendar, and you can shift the Hijri date by up to two days if your country starts months by moon sighting.

Home
• Today's Hijri and Gregorian date, with sunrise and sunset
• A live sky: the sun by day and the moon in its real phase by night
• Your week at a glance, and the fasting days ahead
• Mark today as fasted in one tap

Ramadan and prayer times
• When suhoor ends and iftar begins in your city, with a countdown
• All six prayer times, worked out on your phone with the common calculation methods, including Umm al-Qura, Egyptian and Muslim World League
• A daily checklist: your fast, Taraweeh and Quran pages

Hijri calendar
• Any month from 1356 to 1500 AH, plus a whole-year view
• Each fasting type has its own colour and icon
• Tap a day to see what it is and log it as fasted, missed in Ramadan, or a make-up fast

Reminders
• On from the start for every fasting type
• The evening before, the morning of, or a time you choose
• Suhoor and iftar reminders in Ramadan, timed for your city
• Write your own reminder text and pick its tone
• One notification per day, even when a day is several kinds of fast

Make-up fasts (Qada)
• Mark the Ramadan days you missed, or enter days owed from earlier years
• Log make-up fasts and see how many are left and the days until next Ramadan
• A suggested pace to finish before Ramadan
• Weekly, monthly and before-Ramadan reminders until nothing is owed

Progress
• Your current and longest streak
• This month's and this year's totals for each fasting type

Duas and intentions
• The intention, the dua at iftar, the dua for Laylat al-Qadr and the hadith on each fast, with their sources
• Share any fasting day as an image card

Home-screen widget
• Today's Hijri date and your next fasting day, in your language

Backup and restore
• Save your data to a file and restore it on a new phone, with no account

Announcements
• Occasional notices, such as the confirmed start of Ramadan or Eid

Arabic and English
• Full Arabic with a right-to-left layout, or English
• Light and dark themes

Your data
Your fasting log, reminders and settings are stored on your phone. There's no account and there are no ads. You can pick your city without any permission. If you choose to share your location, only an approximate position is used, to work out the sky and prayer times, and it is kept on your phone. To receive announcements, the app uses Firebase Cloud Messaging, which gives your device a push token. The privacy policy explains the details.

Questions or suggestions: support@fasomo.site
```

## Release notes for 1.0.0 [500]

```text
The first release of Fasomo:
• Sunnah and Ramadan fasting days on the Hijri calendar
• Suhoor, iftar and prayer times in Ramadan
• Reminders for every fasting type, on from the start
• A fasting tracker with streaks and monthly totals
• A make-up (Qada) tracker with its own reminders
• Duas and intentions, with their sources
• English and Arabic, with light and dark themes
```

## Graphics

| Play asset | File | Spec |
|---|---|---|
| App icon | `icon-512.png` | 512 × 512 PNG |
| Feature graphic | `feature-graphic.png` | 1024 × 500 PNG |
| Phone screenshots (7) | `screenshots/01-home.png` … `07-dark.png` | 1440 × 2560 PNG, 9:16 |

Upload the screenshots in file order. Sources and scripts to regenerate them are in `store/src/`.

## Store settings

| Field | Value |
|---|---|
| App or game | App |
| Free or paid | Free (this can't be changed to paid later) |
| Category | Lifestyle |
| Tags | Pick the closest to: Religion, Calendar, Reminders |
| Contact email | support@fasomo.site |
| Website | https://fasomo-7b6c7.web.app |
| Privacy policy URL | https://fasomo-7b6c7.web.app/privacy |

## App content (Policy → App content)

| Section | Answer |
|---|---|
| Privacy policy | https://fasomo-7b6c7.web.app/privacy (links to the Arabic version) |
| Ads | No, the app has no ads |
| App access | All functionality is available without special access (no login) |
| Content rating | Fill in the IARC questionnaire: category "Reference, News, or Educational"; answer No to violence, sexuality, language, controlled substances, gambling, user interaction and sharing location with others. Expected rating: Everyone / PEGI 3 |
| Target audience | 13 and over. Not designed for children, which keeps it out of the Families policy |
| News app | No |
| Government app | No |
| Financial features | None |
| Health | No health features |
| Advertising ID | No, the app doesn't use the advertising ID |

### Data safety

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | Yes |
| Is all of the user data collected by your app encrypted in transit? | Yes |
| Do you provide a way for users to request that their data is deleted? | No. There's no account; uninstalling the app removes the push token, and Firebase deletes inactive tokens on its own |

Data types to declare:

| Data type | Collected | Shared | Processing | Required or optional | Purpose |
|---|---|---|---|---|---|
| Device or other IDs | Yes | No | Not ephemeral | Required | App functionality (delivering announcements) |

Not declared, and why:

- **Approximate location**: used only on the phone for the sky and prayer times, and stored there rounded to about a kilometre. The app never sends it anywhere, so under Play's definition it isn't collected.
- **Fasting log, reminders, settings**: stored only on the phone.

If you later add Crashlytics, Analytics, ads or an account, these answers change, and the privacy policy changes with them.
