# Sinew component and API catalogue

What exists, so nobody rebuilds it. Read the source for details; this is the map.
Everything is metric in storage; convert only for display/input with `lib/core/units/units.dart`.

## Theme (`lib/core/theme/app_theme.dart` exports all of it)

| Accessor on `BuildContext` | Returns |
|---|---|
| `context.cs` | `ColorScheme` |
| `context.colors` | `SinewColors` roles (primary, onPrimary, primaryContainer, onPrimaryContainer, secondaryContainer, onSecondaryContainer, tertiary, tertiaryContainer, onTertiaryContainer, success, onSuccessContainer, warning, onWarningContainer, danger, surface, surfaceContainer, surfaceContainerHigh, outline, divider, onSurface, onSurfaceVariant, onSurfaceMuted, …) |
| `context.accents` | `SinewAccents`: `plate(kg)` fill/edge, `bar`, `barCollar`, `phase(SinewPhase)` field/on/ring, `musclePrimary/Secondary/Idle/Body`, `heat` (5), `series` (8) |
| `context.text` | `TextTheme` (Inter, tabular figures) |
| `context.sectionHeader`, `context.mono`, `context.timerNumeral`, `context.serifAccent` | special type roles |

Tokens: `Space`, `Radii`, `IconSpec`, `Strokes`, `Motion` (`Motion.of(context, d)`, `Motion.curveOf`), `Elevations`, `Opacities`, `Sizes`, `SinewSpace` (gloveTarget 64, timerControl 96, setRowHeight 64), `SinewShape`, `SinewMotion`, plus per-component specs (`PlateSpec`, `SetRowSpec`, `TimerSpec`, `StepperSpec`, `MapSpec`, `SilhouetteSpec`, `StatSpec`, `ChartSpec`, `FieldSpec`, `ExerciseTileSpec`). New sizes go in `tokens.dart`, never inline.

Settings: `settingsProvider` (`AppSettings{themeMode: AppThemeMode(system|light|dark|amoled), familyId, dynamicColor, textScale, onboarded}`), `SettingsController.setThemeMode/setFamily/setDynamicColor/setTextScale/setOnboarded`. `prefsProvider` (SharedPreferences). Families: `kThemeFamilies`, `familyById`, `AppTheme.paletteOf(family, tone)` for previews.

## Shared widgets (`lib/core/widgets/`, ported from Kuber)

- Actions: `AppButton({label, onPressed, type: primary|normal|outline|danger|dotted, icon, fullWidth, isLoading, …})`, `AppIconButton({icon, onPressed, semanticLabel, kind, …})`, `SinewExtendedFab({icon, label, onPressed})` with `sinewFabLocation`; lists add `SinewExtendedFab.clearance` bottom padding. `MinTapTarget`.
- App bar: `SinewAppBar({title, subtitle, actions, showBack, infoConfig: SinewInfoConfig, overflowConfig: SinewOverflowConfig, onBack, search, …})`, `SinewPageHeader({title, subtitle, actions, infoConfig, overflowConfig})` (tab landing pages), `SinewHeaderSearch`, `SinewOverflowButton`, `SinewScrollAwayHeader`.
- Menus/sheets/feedback: `showSinewMenu<T>({context, entries: [SinewMenuEntry(value, label, icon, destructive) / .divider() / .header()]})`, `showSinewBottomSheet<T>({context, builder})` + `SinewBottomSheet({title, subtitle, child, actions})`, `showSinewInfoSheet(context, SinewInfoConfig)`, `showSinewSnackBar(context, msg, {isError, actionLabel, onAction})`, `showSinewUndoSnackBar(context, msg, onUndo:)`, `showSinewConfirmDialog({context, title, message, confirmLabel, destructive}) -> Future<bool>`.
- States: `SinewEmptyState({icon, title, description, actionLabel, onAction})`, `SinewSkeleton`, `SinewSkeletonRow`, `SinewSkeletonCard`, `SinewLoader`, `Delayed({child})` (wrap every loading state so fast loads never flash).
- Choice: `SinewSegmentedControl<T>({values, labels, selected, onSelected})`, `SinewChip({label, selected, icon, onTap, onDeleted, …})`, `SinewDropdownChip<T>`.
- Lists/settings: `SinewSettingsSection({label, children})`, `SinewSettingsCard`, `SinewSettingsTile`, `SinewSwitchRow`, `SinewNavigationRow`, `SinewValueRow`, `SinewSectionHeader({title, trailing})`, `SinewSectionAction`, `SinewCard({child, onTap, hero})`, `SinewGroup`, `SinewListRow({title, leading, subtitle, trailing, onTap, …})`, `SinewChevron`, `SinewIconTile`, `SinewPill({label, tone: SinewTone})`.
- Forms: `SinewTextField({label, controller, hint, suffixText, errorText, keyboardType, …})`, `SinewTextField.number(...)`, `SinewFormSection`, `SinewFieldLabel`, `SinewPickerRow`, `SinewCallout`.
- `showIconColorPicker({context, icons, initial: SinewIconColor, onDone, extraTabs: [SinewPickerTab(id, label, title, builder)]})`.
- Nav: `SinewNavBar`/`SinewNavPill` live in `AppShell`; hide the nav with `ref.read(navHideReasonsProvider.notifier).hide(NavHideReason.x)` and `show(...)` (`lib/core/routing/nav_visibility.dart`).

## Domain widgets (`lib/core/widgets/domain/`)

- `PlateLoader({result: PlateResult, targetKg, bar: Bar, unit, showCaption, onPickNearest, haptics})`, `PlateLoader.stack({targetKg, stepKg, …})`. Animates plate changes per the handoff.
- `SetRow({entry: SetEntry, trackingType, onChanged(SetEntry), onComplete(bool), onLongPress, onTap, previous: SetEntry?, number, weightUnit, distanceUnit, focused, planned, paceLabel, haptics})`, `SetRow.compact(...)`, `SetRow.summary(entry, type, …)`.
- `TimerControls({phase: SinewPhase, paused, onPlayPause, locked, onLock, onUnlock, onAddTime, onSkip, onPrevious, onStop, addSeconds, showLabels, haptics})`, `AmrapCounter({phase, rounds, onAdd, onUndo})`.
- `PhaseField({snapshot: TimerSnapshot, title, trailing, heading, label, nextLabel, warningSec, finishedTitle, finishedSubtitle, controls: Widget})` (fills its parent; parent rebuilds per tick from the engine snapshot), `TimerRing({fraction, ringColor, trackColor, size, strokeWidth, child})`, `sinewPhaseOf(TimerPhase)`, `ClockText.format/parse/spoken`.
- `NumericStepper({value, onChanged, semanticLabel, step, min, max, unit, maxDecimals, glove, haptics, format})`.
- `MuscleMap({primary, secondary, view: front|back|both, fit: contain|crop, sex, tint, heat: Map<String,double>, onRegionTap(String muscleId), showLabels, semanticLabel})`.
- `SilhouetteView({geometry: SilhouetteGeometry, compareGeometry, hasData, animate, highlight: BodyAnchor?, showLevelMarkers, showLevelLabels, onLevelTap, levelValueText, semanticLabel})`, `bodyAnchorLabel(BodyAnchor)`.
- `StatCard<T>({label, result: StatResult<T>, format, unit, category, categoryTone, delta: StatDelta, caption, footer, onInfo, onTap, onLockedAction, lockedActionLabel, compact})`, `StatCard.loading`, `statInputLabel`, `describeStatInputs`.
- `ChartCard({title, primary: ChartSeries(label, points: [ChartPoint(date, value)]), secondary, latestLabel, deltaLabel, range: ChartRange, onRangeChanged, reference: ChartReference, valueFormat, emptyMessage, height})`, `ChartCard.loading`. Caller filters by range and passes display units.
- `FieldUnit.length/weight/plain`, `FieldRow({name, unit, onChanged(double? metric), valueMetric, previousMetric, deltaText, side, estimated, enabled, …})`, `FieldPairRow`, `FieldManagerRow({name, meta, fieldEnabled, onEnabledChanged, paired, dragHandle, overflow, onOverflow, onTap})`.
- `ExerciseTile({exercise: ExerciseSummary, secondaryMuscles, sex, trailing, onTap, onLongPress, selected})`, `ExerciseAddButton`, `ExerciseSelectMark`, `ExerciseTileSkeleton`, `trackingTypeIcon`, `trackingTypeWords`, `prettyVocab`.

## Engines (`lib/engines/`, pure Dart)

- `body_stats/body_stats.dart`: `BodyStatsInput({now, weightKg, heightCm, waistCm, neckCm, hipsCm, loggedBodyFatPercent, sex, birthYear, activityLevel, cutoffs})`; `BodyStats.bmi/healthyWeightRange/bmr/tdee/navyBodyFat/bodyFat/waistToHeight/waistToHip/leanBodyMass` → `StatResult<T>` (sealed: `StatValue{value, approximate, estimated}`, `MissingInputs{missing}`, `InvalidInputs`); `BodyStats.bmiCategory`, `estimateSessionCalories(session, metById, weightKg)`, `kWaistToHeightMarker`.
- `plates/plates.dart`: `PlateEngine.solve({targetKg, bar, inventory, pair})` → `PlateResult`; `snapToStack`; `transition`; `totalFor`.
- `records/records.dart`: `Records.computeRecords(sessions)` → `RecordBook` (`book[exerciseId]` → heaviestWeight, bestE1rm, mostVolumeInSession, longestHold, longestDistance, longestDuration, repsAtWeight); `Records.prSetIds(sessions)`; `Records.sessionVolumeKg`; `Records.epley1rm`.
- `timer/timer_engine.dart`: configs (`StopwatchConfig`, `CountdownConfig`, `IntervalConfig`, `TabataConfig`, `EmomConfig`, `AmrapConfig`, `BoxingConfig`, `YogaFlowConfig(poses: [YogaPose])`, `CustomConfig`) with `toJson/fromJson`; `compile(config)`; `totalDurationMs(steps)`; `TimerRun.start(steps, nowMs, {mode})`, `TimerRun.rest(sec, nowMs)`, `snapshotAt(nowMs)`, `pause/resume/skip/addTime/stop/incrementRound/decrementRound/setLocked`, `cuesBetween(fromMs, toMs, cues)` → `CueEvent{kind, atMs, text, sound, haptic, voice}`, `toJson/fromJson`; `sessionFromRun(run, end, {name, newId})`.
- `silhouette/silhouette_engine.dart`: `SilhouetteInput`, `buildSilhouette(input)`, `SilhouetteGeometry.lerp`, `lerpInputs`.

## Data (`lib/core/providers.dart` is the DI graph; widgets never touch a database)

Repositories (all in `lib/core/db/repositories/`): `profileRepositoryProvider` (Profile get/watch/save), `customExerciseRepositoryProvider`, `routineRepositoryProvider` (watchAll, byId, allWithItems, save, delete), `sessionRepositoryProvider` (active, watchActiveId, start, finish, addExercise, removeExercise, upsertSet, deleteSet, byId, watchHistory, finishedCount, previousSets, allWithTree, saveTree, delete; `ActiveSessionExists`), `measurementRepositoryProvider` (watchFields, fields, saveField, reorderFields, removeField → FieldRemoval, saveEntry, deleteEntry, entries, latestValues, history), `timerPresetRepositoryProvider`, `plateInventoryRepositoryProvider`, `runtimeStateRepositoryProvider` (persist running state by key), `libraryRepositoryProvider` (Future; `search({query, filters: LibraryFilters, limit, offset})` → `ExerciseSummary`s, `count`, `categoryCounts`, `byId`, `byIds`, `flows`, `flowById`), `exerciseSearchServiceProvider` (library + custom merged), `exerciseResolverProvider` (any id → Exercise incl. custom and tombstones), `backupServiceProvider` (export, parse → ParsedBackup/RejectedBackup, restore(preview, mode: replace|merge)), `csvExportServiceProvider`, `lastBackupAtProvider`, `shouldRemindBackupProvider`.

Providers that read a whole table or are keyed by an id are `autoDispose`. Read the DB in a provider, never in `build()`.

## Routing and cross-feature contracts

- `Routes` in `lib/core/routing/router.dart` lists every cross-feature path. Each feature registers its own `GoRoute`s in `lib/features/<f>/<f>_routes.dart` (`<f>TabRoutes` relative to the tab root, `<f>RootRoutes` full-screen with `parentNavigatorKey: rootNavigatorKey`).
- `pickExercises(context, {multiple, exclude, title})` in `lib/features/library/exercise_picker.dart` (Library implements).
- Timer API in `lib/features/timer/api/timer_api.dart`: `backgroundTimerHostProvider` (show(run, cues, title), clear), `cuePlayerProvider` (play(CueEvent, cues)), `screenWakeProvider` (keepOn) (Timer implements; others call).
- Platform: `SinewPlatform.appVersion/speak/stopSpeaking/ringerMode` (`lib/core/platform/platform_channel.dart`).
