"""Finite authored destinations; trusted Godot validates floor and exit reach."""
import math

PLACE_ID = "lourizan"
ARRIVAL = [9.6, 0.05, 0]
MIN_POSITION = [-25, -0.1, -33.4]
MAX_POSITION = [29.8, 6, 33.4]


BOUNDS = {
    "lourizan": (MIN_POSITION, MAX_POSITION),
    "street": ([-16, -1, -50], [12, 8, 50]),
    "scandale": ([-3, -.1, -5], [3, 4, 5]),
}


def valid_position(position, place=PLACE_ID):
    if place not in BOUNDS:
        return False
    low, high = BOUNDS[place]
    if place == "lourizan" and isinstance(position, list) and position and isinstance(position[0], (int, float)) and position[0] < -70:
        low, high = [-99, -.1, -10], [-81, 5, 10]
    return (isinstance(position, list) and len(position) == 3
            and all(type(v) in (int, float) and math.isfinite(v)
                    and minimum <= v <= maximum
                    for v, minimum, maximum in zip(position, low, high)))
