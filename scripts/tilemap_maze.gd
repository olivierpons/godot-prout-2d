extends TileMap

@export var width: int = 150
@export var height: int = 100

@onready var tileset = preload("res://scene/tileset_game.tres")

func _ready():
	randomize()
	print("Checking tiles in the TileMap...")

	for l in range(0, 2):
		for y in range(height):
			for x in range(width):
				var c_s_id = get_cell_source_id(
					l,  # tile_map_layer
					Vector2i(x, y)  # tile_map_cell_position
				)
				var c_a = get_cell_atlas_coords(
					l,  # tile_map_layer
					Vector2i(x, y)  # tile_map_cell_position
				)

				# Afficher seulement les cellules avec des tiles définis
				if c_a != Vector2i(-1, -1) or c_s_id > 0:
					print("Layer ", l, ": ", x, "/", y, " = Atlas Coords: ", c_a, ", Source ID: ", c_s_id)

	# Exemple pour définir une cellule avec un ID de tile aléatoire
	for x in range(width):
		for y in range(height):
			var pos = Vector2i(x, y)
			var random_tile_id = get_random_tile_id()
			if random_tile_id != -1:
				set_cell(
					1,  # Layer
					pos,  # Position de la cellule
					random_tile_id  # ID du tile aléatoire
				)

	print("TileMap checking complete.")

func get_random_tile_id() -> int:
	var tile_ids = []
	var source_count = tileset.get_source_count()
	for source_id in range(source_count):
		var source = tileset.get_source(source_id)
		if source is TileSetAtlasSource:
			for tile_id in source.get_tile_ids():
				tile_ids.append(tile_id)
	if tile_ids.size() > 0:
		return tile_ids[randi() % tile_ids.size()]
	return -1



