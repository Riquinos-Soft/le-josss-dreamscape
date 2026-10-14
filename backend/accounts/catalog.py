"""Wire IDs match the Godot P2 catalog; contract parity is tested."""
OPTIONS = {
    "body": ["human_v1"], "face": ["plain", "freckles"], "hair": ["short", "tied"],
    "upper": ["shirt"], "lower": ["trousers"], "shoes": ["boots"],
    "skin_palette": ["warm", "olive", "deep"], "hair_palette": ["chestnut", "ink"],
    "upper_palette": ["teal", "ochre"], "lower_palette": ["charcoal", "earth"],
    "shoe_palette": ["leather"]}
DEFAULT = {"version": 1, **{key: values[0] for key, values in OPTIONS.items()}}
LABELS = {"face": "Rostro", "hair": "Peinado", "skin_palette": "Piel",
          "hair_palette": "Color del pelo", "upper_palette": "Camisa", "lower_palette": "Pantalón"}
SPANISH = {"plain": "Sin pecas", "freckles": "Con pecas", "short": "Corto", "tied": "Recogido",
           "warm": "Cálida", "olive": "Oliva", "deep": "Oscura", "chestnut": "Castaño",
           "ink": "Negro", "teal": "Verde azulado", "ochre": "Ocre", "charcoal": "Gris", "earth": "Tierra"}


def valid_appearance(value):
    return (isinstance(value, dict) and set(value) == {"version", *OPTIONS}
            and type(value["version"]) is int and value["version"] == 1
            and all(isinstance(value[k], str) and value[k] in choices for k, choices in OPTIONS.items()))
