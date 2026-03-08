extends TileMap

@export var game_manager: Node = null
@export var width: int = 5
@export var height: int = 4
@export var exit_door: Node2D = null
@export var coin: PackedScene = preload("res://scene/coin.tscn")

@onready var grid: Array = []

var mz_width: int
var mz_height: int


func config(	c: Cell, str_link: String, str_wall: String = "") -> bool:
	for dir: String in str_link:
		if (	dir == "N" and c.has_wall(Cell.Dir.N, mz_width, mz_height)):
			return false
		if (dir == "E" and c.has_wall(Cell.Dir.E, mz_width, mz_height	)):
			return false
		if (dir == "S" and c.has_wall(Cell.Dir.S, mz_width, mz_height	)):
			return false
		if (dir == "W" and c.has_wall(Cell.Dir.W, mz_width, mz_height	)):
			return false
	for dir: String in str_wall:
		if (dir == "N" and not c.has_wall(Cell.Dir.N, mz_width, mz_height	)):
			return false
		if (dir == "E" and not c.has_wall(Cell.Dir.E, mz_width, mz_height	)):
			return false
		if (dir == "S" and not c.has_wall(Cell.Dir.S, mz_width, mz_height	)):
			return false
		if (dir == "W" and not c.has_wall(Cell.Dir.W, mz_width, mz_height	)):
			return false
	return true


func _ready() -> void:
	randomize()
	var r: Rect2i = get_used_rect()
	var x_s: int = r.position[0]
	var y_s: int = r.position[1]
	var x_e: int = r.end[0]
	var y_e: int = r.end[1]
	for y: int in range(y_s, y_e):
		for x: int in range(x_s, x_e):
			set_cell(
				1, Vector2i(x, y),
				-1, Vector2i(-1, -1), -1,
			)
	var mz: Maze = Maze.new()
	mz_width = width
	mz_height = height
	mz.generate(mz_width, mz_height)

	if exit_door:
		var p_door: Vector2i = Vector2i(
			(mz_width - 1) * 4 + x_s,
			(mz_height - 1) * 4 + y_s,
		)
		p_door = map_to_local(p_door)
		p_door = to_global(p_door)
		p_door += Vector2i(0, 24)
		exit_door.global_position = p_door

	var total_coins: int = 0
	for y: int in range(mz_height):
		for x: int in range(mz_width):
			var cell: Cell = mz.c(x, y)
			var x_b: int = x * 4 + x_s
			var y_b: int = y * 4 + y_s

			_set_corners(x_b, y_b)

			if not config(cell, "", "S"):
				continue

			_set_floor_tiles(
				x_b, y_b, y, mz_height,
			)

			if total_coins > 0 and randi() % 10 != 0:
				continue

			var glob_p: Vector2i = Vector2i(
				x_b, y_b
			)
			glob_p = to_global(
				map_to_local(glob_p)
			)
			glob_p += Vector2i(0, 18)
			_spawn_coin(glob_p)
			total_coins += 1

	_set_top_walls(x_s, y_s)
	_set_side_walls(mz, x_s, y_s)


func _set_corners(
	x_b: int, y_b: int,
) -> void:
	set_cell(
		1, Vector2i(x_b - 2, y_b - 2),
		0, Vector2i(2, 1),
	)
	set_cell(
		1, Vector2i(x_b + 2, y_b - 2),
		0, Vector2i(2, 1),
	)
	set_cell(
		1, Vector2i(x_b - 2, y_b + 2),
		0, Vector2i(2, 1),
	)
	set_cell(
		1, Vector2i(x_b + 2, y_b + 2),
		0, Vector2i(2, 1),
	)


func _set_floor_tiles(
	x_b: int, y_b: int,
	y: int, max_y: int,
) -> void:
	if y == max_y - 1:
		set_cell(
			1, Vector2i(x_b - 1, y_b + 2),
			1, Vector2i(11, 0),
		)
		set_cell(
			1, Vector2i(x_b, y_b + 2),
			1, Vector2i(13, 0),
		)
		set_cell(
			1, Vector2i(x_b + 1, y_b + 2),
			1, Vector2i(14, 0),
		)
	else:
		set_cell(
			1, Vector2i(x_b - 1, y_b + 2),
			1, Vector2i(6, 2),
		)
		set_cell(
			1, Vector2i(x_b, y_b + 2),
			1, Vector2i(7, 2),
		)
		set_cell(
			1, Vector2i(x_b + 1, y_b + 2),
			1, Vector2i(19, 2),
		)


func _spawn_coin(pos: Vector2i) -> void:
	"""Instantiate a static coin (no falling)."""
	var coin_entity: Node2D = coin.instantiate()
	_disable_coin_falling(coin_entity)
	add_child(coin_entity)
	coin_entity.global_position = pos


func _disable_coin_falling(
	entity: Node2D,
) -> void:
	"""Set fall_delay to 0 before the node enters
	the tree, preventing auto-fall in _ready()."""
	for child: Node in entity.get_children():
		if child is Collectible:
			child.fall_delay = 0.0
			return


func _set_top_walls(
	x_s: int, y_s: int,
) -> void:
	for x: int in range(mz_width):
		var x_b: int = x * 4 + x_s
		var y_b: int = y_s
		set_cell(
			1, Vector2i(x_b, y_b - 2),
			1, Vector2i(9, 0),
		)
		set_cell(
			1, Vector2i(x_b - 1, y_b - 2),
			1, Vector2i(9, 0),
		)
		set_cell(
			1, Vector2i(x_b + 1, y_b - 2),
			1, Vector2i(9, 0),
		)


func _set_side_walls(
	mz: Maze, x_s: int, y_s: int,
) -> void:
	for y: int in range(mz_height):
		for x: int in range(mz_width):
			var cell: Cell = mz.c(x, y)
			var x_b: int = x * 4 + x_s
			var y_b: int = y * 4 + y_s

			if config(cell, "", "E"):
				set_cell(
					1, Vector2i(x_b + 2, y_b - 1),
					1, Vector2i(9, 0),
				)
				set_cell(
					1, Vector2i(x_b + 2, y_b),
					1, Vector2i(9, 0),
				)
				set_cell(
					1, Vector2i(x_b + 2, y_b + 1),
					1, Vector2i(9, 0),
				)
			if config(cell, "", "W"):
				set_cell(
					1, Vector2i(x_b - 2, y_b - 1),
					1, Vector2i(9, 0),
				)
				set_cell(
					1, Vector2i(x_b - 2, y_b),
					1, Vector2i(9, 0),
				)
				set_cell(
					1, Vector2i(x_b - 2, y_b + 1),
					1, Vector2i(9, 0),
				)
