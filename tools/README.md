# Offline tools

Reserved for small repeatable development or asset-preparation helpers. Godot exports and Python's local static server are sufficient for the first milestone; see [development setup](../docs/development.md).

`scaniverse_street/convert.cjs` is an offline helper for the independent Jacobo Risa geometry trial. Download the source `mesh.drc` from the URL in [its provenance note](../game/assets/streets/jacobo_risa/README.md) into ignored `assets/work/scaniverse-2nt4wpvsrhi6zfza/`, run `npm ci --prefix tools/scaniverse_street`, then run `node tools/scaniverse_street/convert.cjs` from the repository root. It writes the reviewed GLB in `game/assets/streets/jacobo_risa/`. Godot does not need Node or the source scan to open the game.
