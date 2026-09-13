# Office Politics

Confidential workplace coaching and office arcade

## Development approach

Build and approve every screen as an isolated visual design before connecting
production logic.

- Design-screen widget classes must end with `DesignScreen`, for example
  `PeopleNetworkDesignScreen`.
- Design-screen filenames must end with `_design_screen.dart`, for example
  `people_network_design_screen.dart`.
- Screen-level variables and route identifiers must also end with
  `DesignScreen`, for example `peopleNetworkDesignScreen`.
- Design screens use fixture data and local UI state only. They must not call
  repositories, Supabase, AI providers, OCR, speech services, ads, or in-app
  purchases.
- Once all design screens are approved, clone them into production screens and
  remove only `Design` from the names:
  `PeopleNetworkDesignScreen` becomes `PeopleNetworkScreen`.
- Connect production screens to domain and service logic incrementally while
  keeping approved design screens as visual references.

The complete screen order and handoff rules are documented in
[DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md). Product requirements are documented
in [OFFICE_POLITICS_PRODUCT_PLAN.md](OFFICE_POLITICS_PRODUCT_PLAN.md).

## Run

```bash
flutter pub get
flutter gen-l10n
flutter run
```
