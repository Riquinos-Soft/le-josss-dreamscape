# ADR 006 — V2 character appearance and scene boundaries

Status: accepted implementation contract for Plan 016 P2, 2026-10-14.
Art acceptance: pending the configurable-character laboratory, not implied by this ADR.
Authorization: developer requested P1 after authorizing the architectural review.
Review performed in this session; no external reviewer or model switch is claimed.

## Context

The current player survives travel because it belongs to Street. Human appearances
are complete baked atlases; changing the face or clothes would require replacing
the whole character. P0 identifies reusable movement/identity boundaries and
inconsistent world/detail density. Preserve recognizable Joss proportions while
making appearance independent from movement, physics, accounts and NPC behavior.

## Decisions

### Scene ownership

- `game/v2/validation/` holds an isolated laboratory entry; production still starts
  at `world/dreamscape.tscn`. No switch or mass migration during P2/P3.
- A V2 session composes a location slot, actors, camera, item representations and
  HUD as siblings. A place owns architecture, collision, spawn/passage markers
  and authored NPC spawn definitions. It never owns the player or durable state.
- `game/v2/characters/` contains the actor controller and appearance presenter.
  A controller receives normalized world-space movement intent; acquisition from
  keyboard/touch/mouse is a separate small adapter. Reuse the existing direction
  helper. Online snapshots later enter the presenter/controller boundary, not UI.
- A location module owns matching visible structure and collider dimensions in
  metres, with explicit connection markers. Visual cutaways never remove collision.
  ADR 005 still governs a physically connected Casa/Bar if that project resumes;
  this does not silently replace it with scene teleportation.
- Direct references and narrow signals connect these components. No global registry,
  event bus, ECS or generic service locator is needed.

### Pose and appearance contract

- Retain the existing 64×64 cell, maximum 48px human body, foot baseline y=60,
  0.0375 metres per pixel and initial orthographic size 13.5. These are the P2
  calibration baseline, not permission to rescale each generated part separately.
- Eight direction keys: down, up, left, right, down_left, down_right, up_left,
  up_right. Each has one straight-leg idle and four walk phases. No random frame
  substitution or independent idle head. Walking phase survives turns; final
  facing survives stopping. Use resolved motion to animate.
- One authored pose template records foot, pelvis, neck and head anchors for every
  direction/phase. All compatible parts share it. A head may bob by the template's
  translation; it must not change size or face between idle and walking frames.
- Appearance configuration contains a format version, body template ID, face ID,
  hair ID, clothing IDs and permitted palette IDs for skin/hair/clothes. IDs are
  catalog values, never resource paths, URLs, source code or uploaded images.
- Parts are original transparent pixel art aligned to the shared template: body/
  skin, facial detail, rear/front hair, upper clothing, lower clothing and footwear.
  Back-facing frames omit facial pixels. Direction-specific layer order handles
  hair/arms/clothes overlap; do not mirror asymmetric features without authored data.
- Compose SpriteFrames once when configuration changes; reuse the result for
  matching configurations and release unused cached compositions. No full-character
  image generation or atlas recomposition every frame. Store appearance IDs/colors,
  not rendered images, as character state. Invalid configurations are rejected on
  save; an unavailable optional part renders a known default without overwriting
  the stored configuration. Unsupported format versions require explicit migration.
- Player and NPC presets use this same presenter. Name, patrol and dialogue remain
  separate. First proof: two visibly different configurations and an NPC preset,
  each checked idle/walking in all eight directions.
- Keep the existing 1.8m capsule and 4m/s base for the laboratory. Appearance never
  changes collision, reach or speed. Mount poses will be an explicit later state;
  do not distort the ordinary body template to accommodate the chicken.

### Environment and import contract

- Crisp nearest sampling, transparent alpha edges without colored fringes, limited
  shade bands and deliberately drawn clusters. Do not generate photographic detail
  and call its downsampling a finished art pass.
- For new sample surface artwork, use the same 0.0375m texel scale: a 32px tile spans
  1.2m. Larger shapes use multiples and authored larger clusters. Physical geometry
  remains in measured metres; do not quantize real-place dimensions to fit textures.
- Tiny window ornament/detail can be coarser to remain legible; higher-resolution
  textures require inspection beside the character. No arbitrary per-asset UV scale.
- Keep original editable masters and prompts outside `game/`; put one normalized
  named derivative in runtime. Stable names/catalog IDs, no numbered draft copies.
  Record grid, anchors, palette and import settings with the asset.
- World and background share day/night grading. HUD is independent. No full-screen
  pixel mosaic, camera redesign or hidden change to character silhouettes is part
  of this contract. Camera tuning must preserve matched comparison captures.

## Alternatives and consequences

Keeping full-character atlases is a useful fallback/reference but cannot deliver
independent appearance choices. Separate generated idle/walk art repeats the
identity problem. A skeleton/deformation renderer would require new rigging and
pixel-stability work without evidence it helps this small character set. Fixed
pose parts and composition reuse the current renderer while making identity data
explicit. The cost is authoring compatible parts and reviewing occlusion across
all poses before multiplying styles.

## Evidence and next gate

`tools/preview_v2_contract.gd` is an offline native calibration scene using current
Joss/Lucas, one 32px/1.2m ground sample and existing window art. Desktop 1280×720
and compact 844×390 captures are in `build/verification/v2/P1/`.
The sample compares idle/walk sizes at the actual camera scale; it is not proof
of composable parts, collision, a completed building or final art acceptance.
Current generated walk poses still vary subtly; P2 must enforce common anchors
and exact face identity instead of accepting those variations as the new template.

P2 is ready to implement this laboratory. Stop expansion if parts cannot preserve
identity or feet drift; fix the shared template before generating more variants.
Physical mobile acceptance remains pending on the developer-confirmed
iPhone 16 Pro + Chrome.

References: [Spec 020](../specs/020-persistent-online-vertical.md),
[Plan 016](../plans/016-persistent-vertical-rebuild.md),
[P0 inventory](../refactor-baseline.md),
[current atlas contract](../../game/assets/art/characters/README.md),
[place authoring](../place-authoring.md).
