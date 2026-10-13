# Street art trial contracts

Authority: the developer's Game Bible and reference sheets; see Spec 002.
All assets below are **draft**, not approved production masters. Nearest sampling
and cutout alpha apply to sprites; their images have no collision of their own.

| Asset | Source / scale / pivot | Use and limitation |
| --- | --- | --- |
| `environments/building_jacobo_garage_facade_night_v01.svg` | Editable native pixel artwork, 144x80; mapped between surveyed facade endpoints (0.1,0.78,16.2) and (-1.9,0.62,23.1) | Main pale facade and identifying windows. Wrapper owns collision and local wall fade. |
| `environments/building_jacobo_garage_door_night_v01.svg` | Editable native pixel artwork, 64x80; mapped between (-1.9,0.62,23.1) and (0.9,0.85,24.0) | Blue-grey garage door; no interior/interaction. |

Faithful: road layout, dark asphalt, garage location/access, pale walls, dark
door, window groupings and green banks. Reinterpreted: flatter facade geometry,
violet/amber palette, stylized plants, sprite character and orthographic camera.
Remaining terrain/vegetation still contains scan facets and requires a later art
pass. Local trial sizes must not be presented as finalized Bible standards.


Character runtime assets are maintained without version suffixes. See
[the canonical character contract](characters/README.md) for the active atlases,
source masters, preparation commands and the future appearance-config direction.
