# Sinew

Sinew is a fully offline Android app, built in Flutter, that tracks workouts of every kind
(strength, calisthenics, yoga, mobility, HIIT, boxing, cardio, pilates) against a bundled
library of 2,890 exercises. It runs exercise timers for every common format, from a plain
stopwatch to Tabata, EMOM, boxing rounds and yoga flows, and keeps them alive in the
background. It also tracks body measurements and derives body stats (BMI, BMR, TDEE, body
fat, ratios) with a silhouette that changes as the numbers do.

It belongs to the family of Material 3 Expressive apps; **Mull** is the house-style
reference and **Kuber** is the source for shared widgets and backup.

**Package:** `com.grs.sinew` (proposed in Phase 1, pending confirmation). Android only,
minSdk 24.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after any freezed/json/drift change
flutter analyze                                            # must be clean
flutter test                                               # must be green
tool/check.sh                                              # all of the above, as CI runs it
dart run drift_dev schema dump lib/core/db/user/user_db.dart drift_schemas/user/   # after a user schema bump
flutter run                                                # on a device or emulator (local machine only)
```

## Stack

Flutter 3.47.9 stable (Dart 3.13.7) · flutter_riverpod 3 · go_router 18 · drift 2.35 +
drift_flutter + sqlite3 3.x (user DB and read-only library, FTS5) · shared_preferences ·
dynamic_color · freezed + json_serializable · fl_chart · flutter_svg · file_picker ·
share_plus · csv. Dev: build_runner, drift_dev, flutter_native_splash, flutter_lints
(Mull's analysis options: strict casts, inference and raw types).

Versions were checked on pub.dev on 2026-10-31 (latest, maintained, publisher known) and are
pinned with carets in `pubspec.yaml`; `pubspec.lock` is committed.

### Timer plugins (Phase 6)

Added together with their native configuration (see `lib/features/timer/`):
- **`flutter_foreground_task` 11.0.3** (pravera.me): the Android foreground service
  and ongoing notification that keep a running timer and its cues alive with the screen off,
  with notification buttons (pause or resume, skip, +10 s). Local only. Service type
  `specialUse` (a workout timer fits no named type; `health` needs body-sensor permissions).
- **`wakelock_plus` 1.8.2** (fluttercommunity.dev): keeps the screen on while the run screen
  is open.
- **No audio plugin.** The five cue sounds, vibration, spoken cues and the ringer mode are
  one small native class, `CueChannel.kt` (`com.grs.sinew/cues`: SoundPool with media usage
  and sonification content, Vibrator, TextToSpeech with speech attributes, a wake lock for a
  counting run). It is registered on the app's engine (`MainActivity`) and on the service's
  engine (`SinewApplication` adds a `FlutterForegroundTaskLifecycleListener`), so the same
  Dart calls (`SinewCues`) work in both isolates. `audioplayers` was dropped: its Gradle
  build predates AGP 9 and it pulled in `http`.
- **Not added: `flutter_local_notifications`.** The service's own notification covers
  everything the timer needs, and the package would require core library desugaring.
- The service plays sound, haptics and voice itself while the app's isolate is silent.
  While a run is paused it slows its tick, drops the wake lock, and after 20 minutes stops
  (the run stays saved and restores on the next open).

Deliberately not added yet:
- **Timer and cue plugins** (`flutter_foreground_task`, `flutter_local_notifications`,
  `wakelock_plus`, an audio player, TTS) arrive in Phase 6 together with their native
  configuration, so they are added and verified as one unit.
- **`flutter_tts`**: Mull dropped it because it applies the Kotlin Gradle Plugin, which
  Flutter is deprecating, and speaks through a small `TextToSpeech` method channel instead.
  Sinew should do the same in Phase 6 (needs sign-off, it departs from the contract's list).
- **`flutter_launcher_icons`**: Mull and Kuber both keep the icon as adaptive vector
  drawables with a monochrome layer, which this tool would rasterise. Phase 9 follows them.
- **`uuid`**: ids are 16 bytes from `Random.secure` (`core/db/ids.dart`); no package needed.

### Database decision

**Drift (SQLite) for both databases.** Isar was checked first, as the contract asks: the
original `isar` package was last published in April 2023 with an SDK constraint below Dart 3,
so it cannot be used at all; the maintained fork `isar_community` (3.4.1, October 2026) is
alive but has no full-text search, and the library needs fast prefix search over 2,890
names, aliases and muscles. SQLite FTS5 does that in well under a millisecond on this size.
Mull also chose Drift, so the family stays on one persistence stack.

- **User DB** (`core/db/user/user_db.dart`): Drift, schema version in `schemaVersion`,
  one migration step per version, a snapshot per version in `drift_schemas/user/`. A file
  from a newer build is refused (`UnsupportedSchemaVersion`), never guessed at.
- **Library DB** (`core/db/library/library_db.dart`): also Drift, but **pure Dart**, so
  `tool/build_library_db.dart` builds the asset with the very same class and the app and
  the script can never disagree about the schema. Built at development time from
  `specs/data/exercises.json`, shipped as `assets/db/library.sqlite` with
  `assets/db/library.version`, copied into app support once per version by
  `LibraryInstaller`, opened read-only (`PRAGMA query_only`) on a background isolate. It is
  rebuilt, never migrated.
- `sqlite3` 3.x bundles SQLite (with FTS5) through Dart build hooks. `sqlite3_flutter_libs`
  is end-of-life and must not be added.

## Offline guarantee

Offline is a hard guarantee. Zero network requests at runtime: no HTTP client, no analytics,
crash reporting, ads, remote config or runtime font fetching. Bundle fonts locally (no
`google_fonts`). Any dependency that phones home is disqualified.

How it is enforced:
- The main `AndroidManifest.xml` declares no `INTERNET` permission, so the OS refuses any
  socket in a release build. (The debug and profile manifests keep it for hot reload.)
- `test/app/guardrails_test.dart` fails if `pubspec.yaml` lists a networking, analytics or
  font-fetching package, or if `lib/` imports `package:http`, uses `HttpClient`,
  `WebSocket`, `NetworkImage` or any `.network(` constructor.
- `flutter_svg` depends on `package:http` for `SvgPicture.network`. It stays (it is on the
  approved list and the muscle map needs it) but only `SvgPicture.asset`/`.string` may be
  used; the guardrail test catches the rest.
- Errors are logged to the device log only (`core/error/error_handling.dart`).

## Theme and token rules

- One source of truth: `lib/core/theme/`. `palette.dart` is the **only** file that names a
  raw colour; `tokens.dart` holds every size, radius, stroke, opacity and duration. A hex
  value or a magic number in a widget is a bug. The guardrail test rejects `Color(0x…)` and
  `Colors.*` outside the theme layer.
- Read colours as `context.colors.<role>` (`SinewColors`, a `ThemeExtension`), type as
  `context.text.<style>`, everything else from `Space`, `Radii`, `IconSpec`, `Strokes`,
  `Motion`, `Elevations`, `Opacities`.
- Phase 1 values are placeholders (Mull's scale, roles derived from the seed with Material's
  tonal-spot scheme). Phase 3 replaces them from the design handoff; role names stay.
- Seed: `#6E8A16`. Dynamic colour takes one wallpaper seed and derives every role exactly as
  the brand seed does. The seed is cached in prefs (`theme.wallpaperSeed`) so a cold start
  never flashes from green to the wallpaper colour.
- `AppTheme.of(tone, seed:)` builds one `ThemeData` (and its `ColorScheme`) per
  (seed, tone) and caches it. Settings are read synchronously from prefs before `runApp`.
- Motion: spring for anything the finger caused, decelerate for anything the system caused.
  Honour reduced motion through `Motion.of` / `Motion.curveOf`.
- Fonts are bundled under `assets/fonts/` (Phase 3). Never fetched.

## Shared components

- `lib/core/widgets/` is the design-system library, built in Phase 3 before any feature
  screen, and consumed everywhere. If you are about to copy a widget, extract it instead.
- **Kuber is the source of truth** for shared widgets and app-level code: the theme
  families and `AppTheme`, the nav pill (`KuberNavPill`), app bar and page header, buttons,
  overflow menu, bottom sheets, settings sections and rows, Theme, About, Permissions,
  More, data management and backup, snackbars, empty/loading/skeleton states, segmented
  control, charts, info sheets and the icon/colour picker. Port them (Riverpod 3, drift,
  bundled fonts, English strings) rather than redesigning. The design handoff
  (`specs/design/sinew-design-references/project/HANDOFF.md`) was itself drawn from
  Kuber's code and decides where it differs. Mull is the reference for motion and folder
  conventions only.
- Phase 1 has only `PhasePlaceholder` (removed screen by screen) and a stock
  `NavigationBar` in `core/routing/app_shell.dart` (replaced by the pill in Phase 3).

## Folder structure

```
lib/
  main.dart                 bootstrap: prefs, user DB open, error handlers, ProviderScope
  app.dart                  MaterialApp.router, cached themes, text scale
  core/
    theme/                  palette (only raw colours) · tokens · typography · app_theme · wallpaper_seed
    settings/               AppSettings + SettingsController (prefs, read before the first frame)
    db/
      user/                 Drift user DB (schema + migrations)
      library/              Drift library DB (pure Dart) + LibraryInstaller
      repositories/         the only code that touches a database
      ids.dart              newId(), Clock
      converters.dart       JSON list column
    models/                 freezed + json models and enums (pure Dart)
    units/                  kg/lb, cm/in, km/mi (pure Dart)
    routing/                go_router (Routes, kTabs) and the tab shell
    error/                  handlers, fallback widget, startup error screen
    widgets/                shared design-system widgets
    providers.dart          the provider graph (DI)
  engines/                  pure Dart, no Flutter imports (Phase 2)
    body_stats/ plates/ timer/ silhouette/ records/
  features/
    today/ train/ library/ timer/ body/ backup/ more/ settings/ about/ onboarding/
tool/
  pipeline/                 Python pipeline that generated specs/data (do not run in the app)
  build_library_db.dart     builds assets/db/library.sqlite (Phase 2)
  check.sh                  analyze + test, as CI runs it
drift_schemas/user/         one JSON snapshot per user schema version
specs/                      data (exercises.json, schema), design handoff (Phase 3)
```

## Data rules

- **Metric storage.** Every value is stored in kg, cm, metres and seconds. Units convert at
  the edges only (`core/units`), for display and input. Never store a converted value.
- **Stable exercise ids.** User data references an exercise by its string id only (library
  ids are kebab-case; custom ids start `custom-`). `ExerciseResolver` looks up custom, then
  library, then `exercise_tombstones`, so a library update that removes an exercise never
  blanks history.
- **schemaVersion everywhere.** The user DB, the library DB (`LibraryDatabase.currentSchemaVersion`
  and `library_meta`), every JSON column payload (timer presets, plate inventory, runtime
  state) and every backup carry one. On read: migrate, or safely skip an unknown/newer
  version. Never crash. Repositories return a default or skip the row.
- **Text ids** (`newId()`, RFC 4122 v4) on every user record, so a restore merges by id
  across devices; `updatedAt` (millisecond ISO-8601) decides a conflict.
- **One active session**, enforced by a partial unique index (`ended_at IS NULL`), and the
  active workout persists after every set (`SessionRepository.upsertSet`).
- **Repositories only.** Widgets never touch a database; they read a repository through a
  provider in `core/providers.dart`. Engines take plain inputs and return plain outputs;
  widgets never compute stats.

## Standing instructions

- Read `specs/design/sinew-design-references/project/HANDOFF.md` and the relevant
  `Sinew N … .dc.html` frames before any UI work. If it is missing when a UI
  phase starts, stop and say so.
- Mull (`github.com/singhgautam7/Mull`) and Kuber (`github.com/singhgautam7/Kuber`) are
  read-only references. Never modify them.
- No new packages without stating the justification first, and none outside the
  contract's list without sign-off. No schema change after Phase 2 without sign-off.
- No analytics, ever. No HTTP client, ever.
- No em dashes in any user-facing string (the guardrail test checks string literals).
- Edge-to-edge everywhere, 48dp touch targets, text scaling to 200% without breakage
  (`test/app/app_test.dart` renders every tab at 2x on a 360dp phone), TalkBack labels,
  reduced motion respected.
- `flutter analyze` and `flutter test` clean before anything is called done. Run
  `dart run build_runner build --delete-conflicting-outputs` after annotation changes.
- Small, described commits. Each phase ends with a pushed branch and a PR titled
  `Phase N: …`.
- Subagents run on Sonnet at medium effort (`model: "sonnet"`, `effort: "medium"`). Every
  brief is exact and self-contained: files and paths, steps, expected values, acceptance
  checks, these hard rules, files it must not touch, and what to report. Verify a subagent's
  work before reporting it.

## Cloud sessions

Development happens in Claude cloud sessions. The container has the Flutter SDK (installed
per session from the stable release archive) but **no Android SDK and no emulator**: there
is no `/dev/kvm`, and `dl.google.com` (Android SDK and Google Maven) is blocked by the
environment's network policy. `flutter analyze` and `flutter test` run here; `flutter build
apk`, `flutter run` and device testing happen locally. Allowing `dl.google.com` in the
environment's network settings would make APK builds possible here (still no emulator).

Riverpod 3 retries failed providers by default; the root `ProviderScope` sets
`retry: noRetry` because offline failures are deterministic. Tests must do the same.

## Known gotchas
