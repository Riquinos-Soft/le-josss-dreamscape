# Spec 003: branded boot splash

Status: implemented; validation recorded below.

## Scope

Replace the default engine startup artwork with the title **Le Joss's Dreamscape**
and a pixel-art illustration guided by the README and references: a familiar stone
town, warm windows, violet night, and a doorway into an impossible world.
Use the engine's built-in splash, including the Web loading page; no extra scene,
artificial loading delay, or gameplay changes. Replace the default engine icon with
a small pixel doorway matching the splash palette.

## Acceptance

- Native boot and exported Web loading use the illustrated game title instead of
  the Godot splash. Artwork keeps its aspect ratio; unused space is dark navy.
- Splash filtering is disabled to preserve pixel edges.
- The project/window and exported browser icon use the doorway instead of Godot.
- Assets are committed inside `game/`; generation is not a runtime dependency.
- Existing automated checks and release Web export still pass.

## Asset provenance

`game/assets/branding/boot-splash.png` is AI-generated using the imagegen skill
for this project, based on the local written visual brief and inspected concept
art. It is illustrative branding, not a screenshot of implemented gameplay.
`game/icon.svg` is an authored pixel-grid doorway in the same palette.

## Validation

Validated on Windows with Godot 4.7.2 on 2026-09-25:

- Import and release Web export succeeded.
- Existing suites: 138 checks, zero failures (13 movement, 32 keyboard,
  63 item lifecycle, 30 courtyard).
- Native Compatibility startup ran for 120 frames and exited successfully.
- Exported HTML uses the custom splash, `object-fit: contain`, pixelated image
  rendering, and `#101020` background; custom browser icons were exported.
- Initial sandbox runs reported certificate-store and settings/log write errors;
  authorized runs outside the sandbox completed without those errors.
- Full uncompressed Web output is 44.93 MiB, above the earlier provisional
  40 MiB budget. The source splash is 2.46 MiB; export includes both loading-page
  artwork and packaged engine resources. Compressed transfer was not measured.
- Artwork was visually inspected. Native splash timing and Chrome/Safari visual
  acceptance remain manual checks; native startup is not browser validation.
