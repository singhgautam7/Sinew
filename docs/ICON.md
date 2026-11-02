# Launcher icon and splash

Mark: **Plate S, variant A (round ends)**, from `GLYPH.plates` / `plateS()` in
`specs/design/sinew-design-references/project/sinew-art.js`. Colours are
`SinewBrand`: dark `#3B4707` (top plate), mid `#6D8817` (bottom plate), tint
`#E4ECC7`. Dark splash uses the design's `#C9D79C` / `#A1B567` strokes on
`SinewBrand.splashDarkTint` `#2A3310`. `flutter_launcher_icons` is not used
(it would rasterise the adaptive layers and drop the themed one), as in Kuber.

## Geometry (512 grid)

Each plate is a ring of radius 62, stroke 34, round caps, around a hub disc of
radius 31 with an 11 radius hole (cut out, so it shows the ground).

| Part | Centre | Arc (clockwise, degrees) | Colour |
| --- | --- | --- | --- |
| Top ring | (256, 194) | 90 to 334 | dark |
| Top hub | (256, 194) | disc | dark |
| Bottom ring | (256, 318) | 270 to 154 | mid |
| Spine join | (256, 194) | 70 to 90, butt ends | mid |
| Bottom hub | (256, 318) | disc | mid |

The whole group is drawn at 0.92 about (256, 256). Arc end points in the SVG
path data are `P(cx, cy, a) = (cx + 62 cos a, cy + 62 sin a)`: 334 on the top
ring is (311.725, 166.821), 154 on the bottom ring is (200.275, 345.179), 70 on
the top ring is (277.205, 252.261). Every arc is `A62 62 0 1 1` (large, sweep)
except the 20 degree join, `A62 62 0 0 1`.

## Adaptive icon (API 26+)

`res/mipmap-anydpi-v26/ic_launcher.xml` and `ic_launcher_round.xml`: background
`drawable/ic_launcher_background.xml` (flat tint), foreground
`drawable/ic_launcher_foreground.xml`, monochrome
`drawable/ic_launcher_monochrome.xml` (same paths, one colour; Android tints it
for themed icons).

The vector drawables keep the 512 grid as their viewport on a 108dp canvas, so
the path data is the design's, unchanged. The one transform is a group scale of
`0.92 * 72 / 108 = 0.6133` about (256, 256): the glyph's own 0.92, times the
72dp visible mask over the 108dp canvas. The glyph then spans about 20dp wide by
37dp tall, well inside the 66dp safe zone (a 33dp radius circle), as the
design's guides show. Strokes and even-odd hub paths are native `<path>` features, so
no arc is flattened.

## Raster art

`flutter test tool/generate_icons_test.dart` paints the same geometry with a
`CustomPainter` and writes:

- `res/mipmap-{m,h,xh,xxh,xxxh}dpi/ic_launcher.png` and `ic_launcher_round.png`
  (48/72/96/144/192 px, tint circle; API 24 and 25 only),
- `assets/icon/play_store_512.png` (square tint),
- `assets/icon/splash.png` / `splash_dark.png` (384 px circle, glyph x 1.155),
- `assets/icon/splash_android12.png` / `splash_android12_dark.png` (1152 px,
  glyph alone on transparent at 0.75 of the canvas; the ground is
  `icon_background_color`).

Then `dart run flutter_native_splash:create` regenerates the splash resources
(`flutter_native_splash:` in `pubspec.yaml`; Android only). Light ground is the
tint; dark ground is the dark scheme surface `#161811`. Re-run both after
changing the art, and commit the output.
