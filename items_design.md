# Item Icons,  Design Reference

Reference for the artwork in `assets/items/`, mapped to element ids via
`lib/data/element_icons.dart`. This file documents *what the artwork is* and how
it was produced, so anyone adding or replacing an icon can match what is already
there.

## Status: complete

**793 of 793 elements have artwork.** Every id in `lib/data/game_data.dart` has a
matching `assets/items/<id>.svg`, and every file in `assets/items/` is referenced
by an id,  no gaps, no orphans. There is no outstanding icon backlog; the old
`icons_needed.txt` list is gone because nothing is missing.

New work on this directory is therefore *replacement or refinement*, not filling
holes. Read the two sections below first,  the set is not stylistically uniform,
and which conventions apply depends on which family you are touching.

## Two artwork families

| Family | Files | Avg size | Origin |
|--------|-------|----------|--------|
| **Flat vector** | 365 | 3.3 KB | Little Alchemy 2 icon set, hand-authored SVG |
| **Traced illustration** | 428 | ~133 KB | raster illustrations auto-traced to vector |

Together ~61.6 MB, of which the traced family is ~54 MB. See
[Size and performance](#size-and-performance),  that number is the main thing to
keep in mind before adding more traced art.

The two families look different on screen: the flat set is geometric and
sticker-like, the traced set is painterly and detailed. They coexist because the
traced art covers subjects (people, monuments, landscapes, dishes) that the flat
style cannot carry at the fidelity the content needs. Match whichever family the
icon you are touching belongs to; do not convert one to the other piecemeal.

---

## Family 1,  Flat vector (365 icons)

**Flat, geometric, sticker-style illustration.** Each icon is a small,
self-contained object rendered as a solid silhouette with no outlines. The style
reads as "cut-paper" or "vector sticker": clean, friendly, instantly legible at
small sizes.

Principles observed across all 365 files:

- **Fills only, no strokes.** Form and detail come entirely from overlapping
  filled shapes, never from outline lines. Edges between a shape and its
  neighbor *are* the linework.
- **Flat color, no gradients.** No `linearGradient`/`radialGradient` anywhere.
  Shading and volume are faked by layering 2–4 tints of the same hue (e.g. a
  light, mid, and shadow blue for water) as separate solid shapes.
- **Primitive-driven.** Assembled from SVG primitives, not just paths: `<path>`,
  `<circle>`, `<rect>`, `<polygon>`, `<ellipse>`. Circles and rects do a lot of
  the work,  highlights, dots, eyes, panels,  which keeps files compact and
  shapes crisp.
- **Single centered subject.** One object per icon, centered, filling most of
  the 100×100 box with a small margin. No backgrounds, no scenes, no text in the
  artwork (the `<title>` tag holds the name for accessibility only).
- **Low detail budget.** Medians sit at **3–4 colors per icon**; ~85% use 6 or
  fewer. A few complex subjects reach 15–25, but the house style favors
  simplicity.

### Format

```svg
<svg id="Layer_1" data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <title>water</title>
  <path fill="#9dc8dc" d="..."/>
  <circle fill="#6ab8d9" .../>
  <ellipse fill="#ebf7fd" .../>
</svg>
```

- **Canvas:** `viewBox="0 0 100 100"` on all 365,  a uniform square coordinate
  space. No `width`/`height`, so the art scales cleanly to any render size.
- **Color as inline presentation attributes**,  `fill="#rrggbb"` directly on each
  shape. No `<style>` block, no `class` attributes.

> **Do not reintroduce CSS classes.** These files originally shipped in the Adobe
> Illustrator export convention,  colors declared once in a `<defs><style>` block
> as `.cls-N { fill:#hex; }` and referenced by `class="cls-N"`. **`flutter_svg`
> does not implement `<style>`**: it logs `unhandled element <style/>`, leaves
> every classed shape with no resolved fill, and renders the whole icon solid
> black. All 365 files were rewritten to inline attributes to fix exactly that.
> If you re-export from Illustrator, choose "Presentation Attributes" for style
> output (not "Internal CSS"), or bake the classes down before committing.
- **`<title>`** holds the human name,  used for semantics, never drawn.
- **No filters, masks, patterns, or embedded raster**, so nothing depends on
  renderer features `flutter_svg` lacks. 14 icons use `opacity`/`fill-opacity`
  for soft accents; everything else is fully opaque.

### Palette

One warm, saturated, harmonized palette,  a modern take on storybook color. It
is *not* tied to the app's "Utsav Modern" UI theme (see the root `DESIGN.md`);
these are illustration colors, chosen per-object for recognizability. There are
~390 distinct fills, clustered tightly around a recurring core:

| Role | Hex | Where it shows up |
|------|-----|-------------------|
| Warm yellow / gold | `#ffc640`, `#ffc63f` | most common fill,  sun, highlights, warmth |
| White | `#fff` | highlights, glints, negative shapes |
| Orange | `#f37d3b`, `#f05c38` | fire, warm accents, warning-warm objects |
| Teal-green | `#09a582`, `#069274`, `#00a69c` | plants, liquids, "life" family |
| Charcoal | `#3e3e3f`, `#231f20`, `#171717` | deep shadows, contrast anchors (used *as fill*, not outline) |
| Sky blue | `#6ab8d9`, `#9dc8dc`, `#ebf7fd` | water, sky, ice,  light→mid→shadow trio |
| Warm brown | `#895e59`, `#714c48`, `#6d4945` | wood, earth, animal fur |
| Neutral gray | `#7d7d7d`, `#58595b`, `#9c9c9c` | metal, stone, rock |

**To color a new flat icon:** pick 2–4 tints of the object's dominant hue (light
highlight, base, shadow) plus one dark near-black for the deepest accents. Reuse
the hexes above wherever the subject overlaps an existing family (any new water
element should use the blue trio; any plant, the teal-greens) so the set stays
cohesive.

---

## Family 2,  Traced illustration (428 icons)

These cover the heritage content,  states, monuments, historical figures,
dishes, dances, textiles. They began as 418×418 RGBA raster illustrations and
were vectorized with [VTracer](https://github.com/visioncortex/vtracer); the
result is genuine path geometry, **not** a raster image wrapped in an `<svg>`
tag. No `<image>` element appears anywhere in `assets/items/`.

### Format

```svg
<?xml version="1.0" encoding="UTF-8"?>
<!-- Generator: visioncortex VTracer 0.6.12 -->
<svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="418" height="418" viewBox="0 0 418 418">
<path d="M0 0 C1.32 0.66 ..." fill="#C9A227" transform="translate(...)"/>
```

Structurally the opposite of the flat family, and that is expected:

- **Inline `fill` per path**, no CSS classes, no `<defs>`,  the same convention
  the flat family now uses, for the same `flutter_svg` reason.
- **Hundreds to a few thousand `<path>` elements** per file, stacked back to
  front; color count is whatever the tracer resolved, not a curated palette.
- **Square canvas at the source raster's size** (mostly `0 0 418 418`), not
  100×100. Uniform coordinates were not preserved across families,  the
  `viewBox` makes that harmless, since the art scales to whatever box
  `ElementIcon` renders it in.
- Still **no gradients, filters, masks, or embedded raster**, so the
  `flutter_svg` compatibility guarantee holds for the whole directory.

### Regenerating or adding traced icons

The conversion is reproducible. With `pip install vtracer`:

```python
import vtracer

vtracer.convert_image_to_svg_py(
    "source.png", "assets/items/<id>.svg",
    colormode="color", hierarchical="stacked", mode="spline",
    filter_speckle=8, color_precision=5, layer_difference=24,
    corner_threshold=60, length_threshold=4.0, max_iterations=10,
    splice_threshold=45, path_precision=2,
)
```

Those numbers are tuned, not defaults,  they were chosen by rendering candidate
settings side by side against the source art:

- vtracer's **defaults** (`filter_speckle=4, color_precision=6,
  layer_difference=16, path_precision=3`) produce ~2.7× larger files with no
  visible gain.
- Anything **leaner** (`filter_speckle=16, color_precision=4,
  layer_difference=32`) roughly halves size again but visibly destroys detail, 
  faces lose eyes and facial hair, textured food flattens into blobs. Do not
  ship it for portraits or busy scenes.

**vtracer emits `width`/`height` but no `viewBox`.** Add one matching those
dimensions after tracing, so the art scales predictably wherever it is rendered.

> **Known inconsistency:** ten of the earliest traced files,  `agartala`,
> `ahilyabaiholkar`, `aizawl`, `ajantaellora`, `akbar`, `alleppeybackwaters`,
> `amaravati`, `amberfort`, `amritsar`, `goldentemple`,  are 500×500 and have
> **no `viewBox`**. `flutter_svg` falls back to `width`/`height` as the viewport,
> so they render, but they are the odd ones out. Worth normalizing if you touch
> them.

---

## Size and performance

| | Files | Total |
|---|---|---|
| Flat vector | 365 | 1.2 MB |
| Traced | 428 | 54.2 MB |
| **All of `assets/items/`** | **793** | **61.6 MB** |

Traced icons average ~133 KB and reach ~578 KB, versus 3.3 KB for a flat icon, 
about 40× heavier. Two consequences worth knowing before adding more:

- **Bundle size.** The traced family dominates app download size.
- **Parse cost.** `flutter_svg` parses SVG at runtime; a few thousand paths costs
  real time on first render of that icon. If a traced icon feels slow to appear,
  that is why,  the fix is a leaner trace or a precompiled
  `vector_graphics` asset, not a change to the widget.

Prefer the flat style for any subject that can carry it. Reach for tracing only
when the subject genuinely needs photographic fidelity.

## Animation

**The icons are 100% static.** No SMIL (`<animate>`, `<animateTransform>`) or
CSS animation (`@keyframes`, `animation:`) in any file. They are still artwork by
design.

Motion is added at the **app layer**, never baked into the asset. Icons render
through `ElementIcon` (`lib/core/widgets/element_icon.dart`) → `SvgPicture.asset`,
and Flutter drives whatever animation the UI wants around that static picture, 
scale/pop on discovery, drag-ghost follow, success flashes (see
`game/presentation/widgets`: `success_flash.dart`, `drag_ghost.dart`,
`showcase_glow.dart`).

Keep new icons static. Do **not** embed SVG animation,  it would fight the app's
animation system and is not guaranteed to render under `flutter_svg`.

## Checklist for a new or replacement icon

Common to both families:

- [ ] Saved as `assets/items/<id>.svg`, where `<id>` is the element id from
      `lib/data/element_icons.dart`,  the filename *is* the mapping.
- [ ] A `viewBox` is present, and the subject is centered with a small margin.
- [ ] No gradients, filters, masks, patterns, or embedded raster (`<image>`).
- [ ] Static,  no animation in the file.
- [ ] Single subject, no drawn text, no background scene.

If matching the **flat** family, additionally:

- [ ] `viewBox="0 0 100 100"`, no `width`/`height`.
- [ ] Solid fills only, no strokes.
- [ ] Colors as inline `fill="#hex"` attributes,  **never** a `<style>` block or
      `class` attributes, which `flutter_svg` ignores (icon renders black).
- [ ] Reuse the core palette hexes for shared material families.
- [ ] 2–6 colors; layer tints to imply volume instead of shading.
- [ ] A `<title>` with the readable name.

If matching the **traced** family, additionally:

- [ ] Traced with the settings above, not vtracer's defaults.
- [ ] `viewBox` added manually after tracing.
- [ ] Checked against the source at small size before committing,  trace
      artifacts hide at full size and show up at icon size.

## Verifying coverage

Coverage should stay at 793/793. To confirm nothing has drifted, compare the ids
in `lib/data/game_data.dart` against the filenames in `assets/items/`; any id
without a file, or any file without an id, is a regression. Note that
`lib/data/game_data.dart` and `lib/data/game_levels.dart` are gitignored,  a
fresh clone builds them from the committed `*.example.dart` templates, which
reference only their own small placeholder icon set.
