extends RefCounted
## Original fictional NPC lines; no live service or real-person attribution.

const JOKES: Array[String] = [
	(
		"El tanatorio de enfrente tiene mejores reseñas que este bar. Claro: allí nadie "
		+ "vuelve a quejarse."
	),
	(
		"Mi abuelo pidió que esparciéramos sus cenizas por su bar favorito. El aspirador de "
		+ "aquí ya tiene herencia."
	),
	(
		"Un cliente me pidió algo que le quitase las ganas de vivir. Le traje la cuenta y el "
		+ "contrato de alquiler."
	),
	(
		"En el crematorio han puesto happy hour: dos por uno, pero tienes que traer a un "
		+ "amigo muy acabado."
	),
	"Mi seguro de vida dice que valgo más muerto. Por fin alguien cree en mi futuro.",
	"Quise donar mi cuerpo a la ciencia. Me contestaron: «Ya tenemos suficientes problemas».",
	"El enterrador me dijo que su negocio estaba muerto. Le dije que dejara de presumir.",
	"Mi familia es muy unida. Desde que repartimos la herencia, solo nos vemos con testigos.",
	"Me han prohibido hacer monólogos en los funerales. Dicen que bastante tienen ya con un muerto.",
	"Puse «descansa en paz» en la puerta de mi negocio. Hacienda entró igual.",
	(
		"El médico me dio seis meses. Como no podía pagarle, me dio otros seis. Eso sí es "
		+ "financiar el futuro."
	),
	(
		"En mi funeral quiero barra libre. Así, por una vez, todos llorarán cuando se acabe "
		+ "algo que puse yo"
	),
]


static func choose(previous: int, rng: RandomNumberGenerator) -> int:
	if previous < 0 or previous >= JOKES.size():
		return rng.randi_range(0, JOKES.size() - 1)
	var selected := rng.randi_range(0, JOKES.size() - 2)
	return selected + 1 if selected >= previous else selected
