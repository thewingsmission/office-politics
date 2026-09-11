# Office Politics — development log

Handoff notes from the first Cursor sessions (11 Sep 2026). Read this plus [OFFICE_POLITICS_PRODUCT_PLAN.md](OFFICE_POLITICS_PRODUCT_PLAN.md) before continuing on another laptop.

**Repo:** https://github.com/thewingsmission/office-politics  
**Branch:** `main`  
**Last pushed commit:** `4daa96d` — Add a landscape Flutter app with local accounts and a premium paywall.

```bash
git clone https://github.com/thewingsmission/office-politics.git
cd office-politics
flutter pub get
flutter run
```

---

## What this app is

Confidential workplace **coaching** app: next-move prediction, people/events, office map, roleplay, reply simulator. Defensive only — do not recommend retaliation, sabotage, rumor campaigns, or real-world harm.

A separate **arcade** layer gamifies access:

- Regular users subscribe to use Coach.
- Daily / weekly / monthly skill contests can grant a time-limited premium pass.
- Rewarded ads buy in-game advantage (time, continues, vision), so people can spend **time** instead of money.
- Arcade stays free to play. Coach is gated.

---

## Conversation decisions (keep these)

### Device and IDs

- Orientation: **landscape only** (iPhone, iPad, Android).
- Bundle / application ID (iOS and Android): `com.thewingsmission.officepolitics`
- Dart package name: `office_politics`
- Languages from launch: English, Simplified Chinese, Traditional Chinese.

### Face lab

- Colleague setup includes a **parametric cartoon face lab** (head, hair, brows, eyes, mouth, office accessories, signature expression).
- No photo-to-face, no photoreal portraits.
- Do **not** store a “hated” field on the coaching profile. Hate is a session target in Slap Desk only.

### Must-have and other arcade games

Shared controls: virtual joystick dash on a **fictional** contest floor (never the user’s real office, real names, or private notes). Cartoon avatars only. Leaderboards show score, not who was slapped.

1. **Slap Desk** (must-have) — dash and slap the session target’s cartoon head. Wrong-person slaps break combo.
2. **Credit Chase** — colleagues wander with stolen credit tokens; trace, slap/yank, catch the flying token. Score = credits taken back.
3. **Rumour Flip** — flick a rumor bubble into cartoon “honest” subtext; listener gets mad; pair cartoon-fights. Score = fights. Fiction only, never the user’s private notes.
4. **5pm Ghost** — slow wanderers with pie-slice vision cones; if the cone overlaps the user, dragged to a 5pm quick sync (fail). Dodge, use obstacles, exit. Score = escape / time / near-misses.

Contest prizes (skill, not lottery): daily → 24h premium; weekly → 7 days; monthly → 1 month.

Ads: continues, extra seconds, slow-mo, reveal patrol/cone. Cap per run. Do not punish ad use on the board. Ad SDKs only in the arcade module, never on case files / OCR / advice.

### Safety split

| Surface | Allowed |
|---|---|
| Arcade | Cartoon catharsis, fights, slap, rumor-flip fiction |
| Coach / roleplay / simulator | Never recommend those as a real next move |
| Office map | Avatars and desks; no hate badges; no slap on a real profile |

---

## Build order we agreed

1. **App skeleton** — done.
2. **Account + paywall shell** — done.
3. Face lab + people records.
4. Shared 2D office engine (camera, joystick, obstacles, NPCs) on a fictional floor.
5. Four arcade modes, Slap Desk first.
6. Contests, rewarded ads, premium-pass grants.
7. Private editable office map.
8. Coaching case file (workspace, relationships, events).
9. AI gateway (consent, keys server-side, advice / simulator / roleplay).
10. OCR, dictation, mottos, macro intel.
11. Store-ready (privacy, ads/IAP disclosures, deletion, beta).

First vertical slice after accounts: **step 4 + Slap Desk**.

---

## What is already in the repo

### Step 1 — Flutter skeleton

- Flutter 3.44 / Dart 3.12, iOS + Android only.
- Riverpod, GoRouter, `flutter_localizations` (EN / `zh` / `zh_TW`).
- Dark office theme (ink / panel / brass) under `lib/core/theme/`.
- Landscape lock: Flutter `SystemChrome`, Android `sensorLandscape`, iOS landscape left/right only.
- Home shell: Arcade / Coach / Map placeholder cards + language chips.

### Step 2 — Account and paywall

- Unauthenticated → `/auth`. Create account or sign in (password ≥ 8 characters).
- **No shared demo login.** Create any email, e.g. `test@example.com` / `password1`.
- Until Supabase keys are passed, accounts are **local** (`SharedPreferences` on device).
- Coach tap without premium → `/paywall`. Subscribe currently grants a **30-day premium flag** (store IAP later).
- Arcade stays marked free. Account chip → export JSON (copied), sign out, delete.
- Cloud path is coded: `SupabaseAccountRepository` + migration `supabase/migrations/20260911000000_profiles.sql` (`profiles`, RLS, `delete_own_account`).
- Enable cloud with:

  ```bash
  flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  ```

  Copy `.env.example`. Apply the SQL migration on the Supabase project. Do not commit real keys (`.env` is gitignored).

### Layout to know

```
lib/
  main.dart
  app.dart
  core/          theme, routing, locale, widgets, config
  features/
    auth/        splash, sign-in / create account
    account/     profile, session, local + Supabase repos
    paywall/
    shell/       landscape home
  l10n/          app_en.arb, app_zh.arb, app_zh_TW.arb
```

`flutter analyze` was clean; widget tests cover language switch, signup, paywall subscribe, export, delete.

---

## Run on another laptop

Need Flutter stable (this machine used **3.44.0**), Android SDK and/or Xcode.

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter emulators --launch Pixel_6_API_36   # or any AVD
flutter run -d emulator-5554
```

Hot reload is not enough after adding native plugins (`shared_preferences`, `supabase_flutter`); do a full `flutter run`.

GitHub push from this machine used account `thewingsmission` via Git Credential Manager. If `git push` hangs, try:

```bash
git -c credential.https://github.com.username=thewingsmission push origin HEAD
```

---

## Next prompt you can paste into Cursor

> Continue Office Politics from DEVELOPMENT_LOG.md and OFFICE_POLITICS_PRODUCT_PLAN.md. Steps 1–2 are done (landscape Flutter shell, local auth, paywall). Build step 3: cartoon face lab on colleague setup, then step 4: shared 2D office engine with joystick on a fictional floor. Keep coaching private and arcade cartoon-only. Device is landscape; bundle id com.thewingsmission.officepolitics.

Do not implement AI advice, OCR, or store IAP until the floor engine and Slap Desk exist unless the user asks otherwise.
