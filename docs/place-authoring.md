# Authoring real places

This is the standing workflow for every new real location and substantial remake.
The developer established it on 2026-10-06 after rejecting the filtered Lourizán scan.

1. Inspect the scan as an offline spatial reference: proportions, building footprint,
   path widths, levels, stairs and entrances. Record which dimensions are measured
   and which are estimates. Keep one unit equal to one metre in the playable model.
2. Inspect photographs from several useful views, including developer photos when
   available. Record source links and coverage. Identify 3–6 defining landmarks.
   Photos inform original game art; do not redistribute them as textures without rights.
3. Block out the architecture and paths from those references. Give walls, roofs,
   stairs, windows and garden beds coherent volumes and connections. Keep the
   characteristic silhouette, proportions and materials recognizable.
4. Author the visible place with reusable modules and the established pixel art
   palette. Use the scan for comparison. Filtering a noisy scan, posterizing its
   photograph or layering a rectangular floor patch over it is not a finished pass.
5. Align simple collision with the visible geometry. Walk arrivals, exits, stairs
   and important approaches using the real player controller. Do not invent access
   to undocumented interiors; label any simplified or inferred layout honestly.
6. Compose the arrival view and inspect the real gameplay camera at representative
   points. Check landmark recognition, player scale, vegetation placement, occlusion,
   material consistency and ground continuity. Iterate when the image is poor even
   if automated tests pass.
7. Save concise source/provenance notes, native captures and validation evidence.
   Run relevant tests and Web export. Report visual limitations separately from
   technical success; developer approval is what accepts the final art direction.

Lourizán example: glazed wings, central clock pavilion, slate mansards, paired
monumental stairs, raised balustraded terrace and planted forecourt. The scan
provides spatial evidence; clean authored geometry expresses these landmarks.

## Retro presentation direction — 2026-10-06

The developer selected Secret of Evermore as a visual reference. Aim for readable
character silhouettes, restrained earthy colours and deliberate light/shadow
clusters in original art. Preserve small details at the gameplay camera scale;
do not rely on a coarse full-screen pixel mosaic to create the style. Character
turns should preserve walking phase and tolerate small analog direction noise.
Use the shared directional presentation helper for eight-way characters.

[Spec 015](specs/015-retro-character-clarity.md) starts with character clarity
and motion. After the requested mobile review, refine Lourizán's facade against
photographs: continuous glazed galleries, their vertical divisions, slate
mansards, clock pavilion, terrace and the shape of the paired stairs. Establish
reusable window, cornice, stone and stair modules as those parts are authored.
Screenshot references inform the visual vocabulary; commercial game sprites or
textures must not enter runtime assets.
