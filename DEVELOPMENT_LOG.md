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

## Screen-first build order

Do not build feature logic vertically yet. First create every screen as an
individually runnable, presentation-only design using realistic fixture data.
Review and refine the complete user experience before connecting repositories,
Supabase, AI, OCR, speech, ads, in-app purchases, or game services.

### First-launch screen map

`Splash` → `Language Setup` → `Privacy Notice` → `Name Setup` → `Auth` →
`Workspace Setup` → `Face Lab` → `Home`

`Workspace Setup` contains four sequential collection views after its
introduction:

1. **Workplace** — industry, department, location, culture, structure, current
   situation, and anything else the user considers important.
2. **Yourself** — role with responsibilities, sex, exact or approximate age,
   tenure, goals, and other important context.
3. **First Colleague** — pseudonym, role with responsibilities, sex, exact or
   approximate age, observed style, and other person-specific information.
4. **Relationship With You** — how the pair works together, major shared
   events, current dynamic, a five-level relationship score, and other
   pair-specific information.

Colleague details and relationship details remain separate so future people can
have their own profiles and directional pair relationships.

### Required design-screen naming

- Every design-screen widget class ends with `DesignScreen`, such as
  `CharacterEditorDesignScreen`.
- Every design-screen filename ends with `_design_screen.dart`, such as
  `character_editor_design_screen.dart`.
- Every screen-level variable and route identifier ends with `DesignScreen`,
  such as `characterEditorDesignScreen`.
- Design screens may use local UI state for interactions, animations, form
  validation, dragging, and navigation previews, but use fixture data only.
- Shared components do not need the suffix unless they represent a full screen.
- Keep all design screens after production work begins; they remain visual
  references and a manual design gallery.
- After all designs are approved, clone each screen and remove `Design`:
  `CharacterEditorDesignScreen` becomes `CharacterEditorScreen`. Connect logic
  only in the production clone.

### Stage A — foundation and entry screens

1. `DesignGalleryDesignScreen` — searchable launcher for every design screen,
   device-size presets, language switcher, and light/dark state previews.
2. `SplashDesignScreen` — startup and loading states.
3. `LanguageSetupDesignScreen` — English, Simplified Chinese, and Traditional
   Chinese selection.
4. `PrivacyNoticeDesignScreen` — first-use warning, pseudonym guidance, and
   third-party AI consent preview.
5. `AuthDesignScreen` — sign in, create account, validation, and error states.
6. `HomeDesignScreen` — primary Arcade, Coach, Map, account, and premium entry.
7. `AccountDesignScreen` — profile, language, subscription, export, sign out,
   and delete account.
8. `PaywallDesignScreen` — plans, feature comparison, restore, and purchase
   states.

### Stage B — people and case-file screens

9. `WorkspaceSetupDesignScreen` — four guided views for workplace, self, first
   colleague, and the user-colleague relationship.
10. `PeopleNetworkDesignScreen` — moving characters, persona selection,
    collision-safe motion, and relationship gestures.
11. `CharacterEditorDesignScreen` — a two-stage colleague-details and
    user-colleague relationship flow reused by both Create Colleague and Modify
    Persona.
12. `FaceLabDesignScreen` — the first-launch flow edits self and first
    colleague; later create/modify flows edit only the selected colleague.
13. `CharacterProfileDesignScreen` — selectable self/colleague profiles with
    avatar, persona, all recorded setup information, on-the-fly related events,
    and a relationship-edit action for non-self profiles.
14. `RelationshipEditorDesignScreen` — create or modify either a
    self-colleague or colleague-colleague relationship, with both personas,
    shared events, current dynamic, and a five-level score.
15. `RelationshipEditorDesignScreen` — four create/modify and pair-type modes,
    both avatars and personas, Step 4 details, and relationship score.
16. `EventTimelineDesignScreen` — dedicated Home category with chronological
    event cards, participant filtering, inspection, and Add Event.
17. `EventEditorDesignScreen` — combined inspect/create modes, date/time,
    involved people, detailed story, personal feeling, LLM extraction, and
    adjustable political-impact, stress, urgency, and evidence-confidence bars.
18. `ArtifactViewerDesignScreen` — source image/text, OCR result, provenance,
    retention, and delete controls.

### Stage C — coaching input and output screens

19. `AdviceInputDesignScreen` — question, goal, selected people/events, typed
    context, image, and voice entry.
20. `ImageCaptureDesignScreen` — camera/gallery entry, crop, rotate, and
    perspective preview.
21. `OcrReviewDesignScreen` — image beside editable recognized text, region
    selection, confidence, and optional redaction.
22. `VoiceInputDesignScreen` — 55-second countdown, live transcript,
    pause/continue segments, correction, and locale state.
23. `AdviceResultDesignScreen` — observations, unknowns, hypotheses, evidence,
    recommendation, scripts, risks, and escalation guidance.
24. `ReplySimulatorInputDesignScreen` — incoming message plus reply A/B/C and
    user goal.
25. `ReplySimulatorResultDesignScreen` — conditional response branches,
    warning indicators, harm/benefit, reversibility, ranking, and comparison.
26. `PredictionOutcomeDesignScreen` — record what actually happened and compare
    it with prior branches.
27. `RoleplaySetupDesignScreen` — person, goal, tone, difficulty, and scenario.
28. `RoleplaySessionDesignScreen` — conversation turns, voice/text response,
    pause, and exit.
29. `RoleplayFeedbackDesignScreen` — clarity, evidence, boundaries, risks, and
    retry.
30. `AdviceHistoryDesignScreen` — previous sessions, saved scripts,
    predictions, and outcomes.

### Stage D — office, knowledge, and intelligence screens

31. `OfficeMapListDesignScreen` — saved office layouts and templates.
32. `OfficeMapEditorDesignScreen` — isometric drag-and-drop floor builder with
    shaped walls, desks, chairs, partitions, rooms, character seats, selection,
    rotation, and undo/redo.
33. `OfficeCharacterPanelDesignScreen` — selected person summary and shortcuts
    from the map.
34. `BusinessOutlookDesignScreen` — current macro signals, citations, age,
    confidence, affected business factors, and refresh state.
35. `IndustryProfileDesignScreen` — countries, products, customers,
    competitors, regulation, and optional ticker.
36. `MottoFeedDesignScreen` — contextual motto cards with source,
    interpretation, misuse warning, save, and share.
37. `MottoLibraryDesignScreen` — browse, search, filter, and favorites.
38. `ScenarioLibraryDesignScreen` — sourced office-politics patterns, evidence
    tiers, case studies, and related advice.
39. `ScenarioDetailDesignScreen` — actors, timeline, signals, alternatives,
    outcomes, responses, caveats, and citations.

### Stage E — arcade screens

40. `ArcadeDesignScreen` — game selection, passes, contest status, and
    rewards.
41. `SlapDeskDesignScreen` — playable fictional gameplay with its instructions
    embedded in the game screen.
42. `CreditChaseDesignScreen` — playable fictional gameplay with its
    instructions embedded in the game screen.
43. `RumourFlipDesignScreen` — playable fictional gameplay with its
    instructions embedded in the game screen.
44. `FivePmGhostDesignScreen` — playable fictional gameplay with its
    instructions embedded in the game screen.
    Each of the four game screens presents pause/resume controls and final
    results as popup windows rather than separate screens.
45. `ContestListDesignScreen` — daily, weekly, and monthly skill contests.
46. `LeaderboardDesignScreen` — score-only ranking, season, and personal best.
47. `RewardedAdOfferDesignScreen` — continue/time/slow-mo/reveal choices and
    cap state.
48. `PremiumPassDesignScreen` — earned pass status and expiry.

### Stage F — settings and complete-state review

49. `SettingsDesignScreen` — language, appearance, notifications, AI provider,
    data, accessibility, and legal links.
50. `DataControlsDesignScreen` — retention, export, deletion, consent history,
    and provider permission.
51. `NotificationCenterDesignScreen` — macro updates, contest results, and
    saved reminders.
52. `HelpSafetyDesignScreen` — limitations, reporting/escalation resources, and
    emergency guidance.
53. Review every screen in all three languages and representative phone/tablet
    sizes, including loading, empty, error, offline, locked, and premium states.
54. Freeze approved screen contracts: required input data, emitted user
    actions, navigation destinations, and reusable components.

### Stage G — clone and connect production screens

55. Clone approved design screens into production files and remove `Design`
    from class, filename, variable, and route names.
56. Connect navigation and session state without changing approved layouts.
57. Connect account, subscription, and data-control logic.
58. Connect workspace, people, relationships, events, artifacts, and office-map
    repositories.
59. Connect OCR and speech services.
60. Connect the AI gateway, advice, reply simulation, roleplay, mottos, and
    macro intelligence.
61. Connect arcade engine, contests, rewarded ads, premium grants, and IAP.
62. Add unit, widget, golden, integration, privacy, accessibility, and device
    tests; then complete store-readiness work.

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

> Continue Office Politics from DEVELOPMENT_LOG.md and
> OFFICE_POLITICS_PRODUCT_PLAN.md. Follow the screen-first build order. Create
> the next presentation-only screen with fixture data and local UI state. Every
> full design-screen class, filename, screen variable, and route identifier must
> end with DesignScreen / `_design_screen.dart`. Do not connect repositories,
> Supabase, AI, OCR, speech, ads, IAP, or production logic until all design
> screens have been reviewed and approved.

Start with `DesignGalleryDesignScreen`, then proceed through the numbered list.
Clone and connect production screens only after Stage F approval.
