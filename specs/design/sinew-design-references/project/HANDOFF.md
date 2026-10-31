# Sinew — design handoff

Sinew is the ninth app in the family (local-first Flutter, Material 3 Expressive). The design follows Kuber's code: `theme_families.dart`, `app_theme.dart`, `kuber_nav_bar.dart`, `kuber_app_bar.dart`, `settings_section.dart`, `data_management_screen.dart` and `about_sections.dart`. The "family design system" project attached to this one was empty, and Mull's source wasn't available, so where the brief says "like Mull", I used Kuber's implementation, which is itself copied from Mull and Perch.

## Files

| File | Contents |
|---|---|
| `Sinew 1 Foundations.dc.html` | Palette, all 9; Sinew scheme in light and dark; dynamic examples; fixed accents; type/space/shape/motion; both icon concepts; every icon format; the sibling row |
| `Sinew 2 Components.dc.html` | Live plate loader, plate key frames, edge states, silhouette states, muscle map, set rows for every tracking type, list rows, chips, stat cards, field row, timer controls, chart card |
| `Sinew 3 First run and Today.dc.html` | Splash, Welcome, Quick profile, Restore backup, Today (populated / rest day / new user / loading), Global search |
| `Sinew 4 Train.dc.html` | Routines (populated / empty / loading), Routine editor, History (populated / empty + loading), Session detail, Active workout (barbell, dumbbell + inline rest), Rest expanded, Swap sheet, Finish summary, other set types in context, Exercise history |
| `Sinew 5 Library.dc.html` | Browse, Search + filters, Filter sheet, No results + loading, Exercise detail (top + scrolled), Pose detail, Create custom exercise |
| `Sinew 6 Timer.dc.html` | Timer home, Interval setup (live total), Custom sequence, Stopwatch, Running work / rest, Paused + locked, Finished, Boxing 10s warning, Yoga flow, AMRAP counter, Lock screen + notifications |
| `Sinew 7 Body.dc.html` | Overview, No data, Add entry, Fields manager, Edit field sheet, Progress, Compare (scrubber), Region tap, Loading, Stat info sheet |
| `Sinew 8 More.dc.html` | More, Profile, Units, Plates and bars, Backup and restore, Export sheet, Settings, Theme, About, Permissions |
| `NavPill.dc.html` | The floating nav pill (Kuber `KuberNavPill` geometry) with Sinew glyphs |
| `sinew-art.js` | Reference renderers for the icon, barbell/dumbbell/stack, muscle map and silhouette. Port the geometry to CustomPainters. |
| `tokens/sinew_tokens.dart` · `tokens/sinew_tokens.json` | Token additions |

Every frame is 390 × 844. As you asked, each screen is drawn in one theme (seed light, seed dark or dynamic), with the themes spread across the set.

## Tokens

- **Palette.** Brief → tuned: dark `#3A4710 → #3B4707`, mid `#6E8A16 → #6D8817`, tint `#EDF4CC → #E4ECC7`. I measured the eight siblings in OKLCh and matched their L/C steps. Hue 121 keeps Sinew 24° from PostPurush (145). The brief's tint was lighter and more saturated than all eight siblings.
- **Scheme.** A new `MullFamily('sinew')` (neutral hue 118 at chroma 1.2; primary hue 121, L .55, chroma .13; container chroma .045). It is built by the exact Kuber formula and surface rule. `guardedLightness` steps the light primary down to L .53 (`#617600`), which passes 4.5:1 on cards and under white.
- **Fixed accents**, all harmonised toward the primary hue (half the distance, max 15°), or toward the wallpaper hue in dynamic mode:
  - plates: IWF order, light and dark
  - timer phases: work, rest, warm-up and cool-down fields, each with an on-colour and a ring colour
  - heat ramp
  - muscle-map primary and secondary
  - 8 chart series using Kuber's categorical hues
- **Contrast.** Phase on-colours are ≥ 9.9:1 and phase rings ≥ 5.6:1. Light chart series are ≥ 3.8:1 on `surfaceContainer`, dark series ≥ 7.9:1.
- **New metrics:** `gloveTarget` 64, `timerControl` 96, `setRowHeight` 64, `timerPrimary` radius 32, and the `timerNumeral` type role (150/150 w700 −6, scales to fit).

## Motion

| Moment | Values |
|---|---|
| Plate enter | translateX 46 → 0, 420ms `easeOutBack` (≈ spring m1 k380 d22), 45ms stagger inside → out, `selectionClick` per plate |
| Plate exit | 220ms `easeOutCubic`, outermost first. Plates that stay never move. |
| Set complete | check scale 0 → 1.18 → 1 over 260ms, `lightImpact`, row fill crossfades 150ms |
| PR | one 600ms `primaryContainer` pulse on the row plus a PR pill. No confetti. |
| Silhouette morph | 480ms `easeOutCubic`, lerps the measurements, then the path |
| Phase change | colour sweeps outward from the ring, 360ms |
| Nav indicator | 220ms spring (Kuber `navIndicator`) |
| Reduced motion | plates and silhouette jump to the end state; phase change is a 90ms crossfade |

## Icon

**Plate S**, two variants pending your pick: **A** round ends (`GLYPH.plates`) and **B** cut ends (`GLYPH.platesCut`). Two weight plates seen face-on (rim, face and centre hole), each open on one quarter; the top one is dark, the bottom one mid, and they meet at the spine to form the S. Formats currently render A.

Export these from the 512 geometry in `sinew-art.js` (the chosen `GLYPH` entry):

- **Play Store 512:** square tint background.
- **Adaptive icon:** 108dp foreground layer with the glyph scaled for the 72dp mask, well inside the 66dp safe zone; flat tint background layer.
- **Themed icon:** monochrome layer.
- **Splash:** glyph on a tint circle in light mode, on a `#2A3310` circle in dark mode.

## Navigation

The five tabs from the brief are kept: Today, Train, Timer, Body, More. The pill uses Kuber's exact geometry (56 tall, padding 8, 40 items, 2dp gap, active = `secondaryContainer` with icon and label), with no FAB. The five glyphs are drawn in the Perch nav language (20×16 art, 1.75 stroke, round). The More glyph is Kuber's grid.

The nav hides during the active workout, the rest timer and every running timer. Screens that need a create action use an extended FAB inside the screen ("New routine", "Add entry"), never a slot in the nav. The five tabs didn't fight the pill: with labels it measures about 300dp, which fits at 360dp.

## Departures and v1 simplifications

1. **Mull reference.** Not available, so the nav, header, Settings/More rows, Theme and About follow Kuber's current M3 code. Check them against Mull's screens before build.
2. **Nav spacing.** The brief says "generously spaced". I kept Kuber's 2dp item gap, which the code says came from Perch. If Mull's pill is wider, change only the gap.
3. **Theme family swatches.** The other families on the Theme screen are approximate dark primaries. Pull the real ones from `MullFamily.palette(dark:)`.
4. **Silhouette.** v1 is a front view built from 10 levels (height, neck, shoulders, chest, waist, hips, bicep, forearm, thigh, calf), smoothed with Catmull-Rom. Torso widths are circumference × 0.36 and limb widths circumference ÷ π. Each segment is dashed if either of its end measurements is missing. No side view in v1.
5. **Muscle map.** 15 regions, front and back, built from simple rounded shapes, with male and female bases picked from Profile → Sex (male when blank). Neck, hands, feet and the hip flexors are drawn as body, not as muscles. List tiles use `fit="crop"`: one side (the one with more primary muscles) zoomed to the worked muscles so it fills the tile. Routines can tint the map with a colour (`color` attribute) or swap it for an icon and colour, using Kuber's `showIconColorPicker` sheet with a third "Muscle map" tab.
10. **AMOLED.** A fourth theme mode for every family: #000000 surface, containers stepped from black, onSurface and onSurfaceVariant taken from the family tint and mid tones. It replaces the old "Pure black" toggle. Timer phases in AMOLED keep a black field and colour the numerals and ring. Tokens in Foundations (`schemeA`); add them to `sinew_tokens.dart` as `SinewScheme.amoled`.
11. **Silhouette and muscle map follow Sex.** Body screens read Profile → Sex for the base; the Body DC has a `sex` prop to preview both.
6. **Body fat.** US Navy method only. Other formulas can come later behind the info sheet.
7. **Calories per workout.** MET × body weight × hours, using the 2024 Compendium. It is always labelled as an estimate.
8. **Dumbbells** are modelled as adjustable (2 kg handle with 5 / 2.5 / 1.25 plates). Fixed dumbbells could be a later setting.
9. **CSV export** is read-only. Only JSON restores, as in Kuber.

## Open questions

- Is a weekly-goal ring on Today wanted? I left it out to avoid streak pressure.
- Do you want the active workout to support landscape for a phone on a bench?
