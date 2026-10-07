extends RefCounted
## Local conversation variants for the fictional Lourizán guide.

const SPEAKER := "Lucas Maconheiro"
const SOURCE_URL := "https://blog.turismo.gal/paseo-romantico-por-el-pazo-de-lourizan/"
const DIALOGUES: Array[Array] = [
	[
		"Bienvenido a Lourizán. Antes del palacio hubo aquí una granja del siglo XV.",
		"El palomar nos recuerda aquella etapa."
	],
	[
		"Eugenio Montero Ríos hizo de Lourizán su residencia de verano.",
		"Aquí impulsó el palacio, el invernadero y los jardines."
	],
	[
		"La escalinata imperial tiene presencia, ¿verdad?",
		"Las estatuas parecen vigilar que nadie suba corriendo."
	],
	[
		"Entre los árboles del jardín hay robles, castaños, cedros y magnolios.",
		"Cada cual tiene su propio ritmo."
	],
	[
		"Las camelias ponen un poco de color al paseo.",
		"A mí me recuerdan que el jardín también sabe sorprender sin hacer ruido."
	],
	[
		"Desde 1943, la finca está ligada a la enseñanza y la investigación forestal.",
		"Un buen sitio para aprender mirando hacia arriba."
	],
	[
		"Consejo de guía: al pasear, mira tanto los edificios como los árboles.",
		"Lourizán tiene historias en las dos direcciones."
	],
	[
		"A veces el mejor plan es bajar el ritmo y escuchar las hojas.",
		"Deja que el camino te enseñe el resto."
	],
	[
		(
			"¿Por qué el mapa de Brasil siempre sonríe? "
			+ "¡Porque tiene una extensión enorme de alegría!"
		)
	],
	[
		"¿Qué le dijo una hamaca a otra en Brasil? «Aquí sí que sabemos tomarnos las cosas con calma»."
	]
]


static func choose_dialogue(previous_index: int = -1) -> int:
	var choice := randi_range(0, DIALOGUES.size() - 1)
	if DIALOGUES.size() > 1 and choice == previous_index:
		choice = (choice + randi_range(1, DIALOGUES.size() - 1)) % DIALOGUES.size()
	return choice
