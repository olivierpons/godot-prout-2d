extends TileMap

@export var width: int = 5
@export var height: int = 4
@export var exit_door: Node2D = null
@export var coin: PackedScene = preload("res://scene/coin.tscn")

@onready var grid: Array = []

func _ready():
	randomize()
	# show an array of all cells of a layer! print(get_used_cells(1))
	# print dimensions of the whole TileMap! print(get_used_rect())
	var r: Rect2i = get_used_rect()
	# print(r, " / ", r.position, " / ", r.end)
	var x_s: int = r.position[0]
	var y_s: int = r.position[1]
	var x_e: int = r.end[0]
	var y_e: int = r.end[1]
	for y in range(y_s, y_e):
		for x in range(x_s, x_e):
			# From doc, set all to -1 to erase the cell:
			set_cell(1, Vector2i(x, y),  -1, Vector2i(-1, -1), -1)
	var mz: Maze = Maze.new()
	var mz_width: int = int(int(r.size[0]) / 4)
	var mz_height: int = int(int(r.size[1]) / 4)
	# mz_width = 60
	# mz_height = 40
	mz.generate(mz_width, mz_height)
	# mz.dump()
	if exit_door:
		# exit_door.position = v_exit_door
		var p_door: Vector2i = Vector2i((mz_width-1)*4+x_s, (mz_height-1)*4+y_s)
		# First convert "tiles" coordinates to real "pixel" coordinates:
		p_door = map_to_local(p_door)
		# Then convert the real "pixel" coordinates to global:
		p_door = to_global(p_door)
		# Then small y offset, hard coded for the door:
		p_door += Vector2i(0, 24)
		exit_door.global_position = p_door

	for y in range(mz_height):
		for x in range(mz_width):
			var cell: Cell = mz.c(x, y)
			var x_b: int = x*4 + x_s
			var y_b: int = y*4 + y_s
			var glob_p: Vector2i = to_global(map_to_local(Vector2i(x_b, y_b)))
			var _coin: Area2D = coin.instantiate()
			_coin.delay_before_falling = -1.0
			add_child(_coin)
			_coin.global_position = glob_p

			# 0, Vector2i(2, 1))
			set_cell(1, Vector2i(x_b - 2, y_b - 2), 0, Vector2i(2, 1))
			set_cell(1, Vector2i(x_b + 2, y_b - 2), 0, Vector2i(2, 1))
			set_cell(1, Vector2i(x_b - 2, y_b + 2), 0, Vector2i(2, 1))
			set_cell(1, Vector2i(x_b + 2, y_b + 2), 0, Vector2i(2, 1))

			if cell.has_wall(Cell.Dir.S, mz_width, mz_height):
				set_cell(1, Vector2i(x_b - 1, y_b + 2), 0, Vector2i(12, 0))
				set_cell(1, Vector2i(x_b    , y_b + 2), 0, Vector2i(13, 0))
				set_cell(1, Vector2i(x_b + 1, y_b + 2), 0, Vector2i(15, 0))
			# Never try Cell.Dir.N, because Cell.Dir.S do the job:
			# if cell.has_wall(Cell.Dir.N, mz_width, mz_height):
			if y == 0:
				set_cell(1, Vector2i(x_b    , y_b - 2), 1, Vector2i(9, 0))
				set_cell(1, Vector2i(x_b - 1, y_b - 2), 1, Vector2i(9, 0))
				set_cell(1, Vector2i(x_b + 1, y_b - 2), 1, Vector2i(9, 0))
			if cell.has_wall(Cell.Dir.E, mz_width, mz_height):
				set_cell(1, Vector2i(x_b + 2, y_b - 1), 1, Vector2i(9, 0))
				set_cell(1, Vector2i(x_b + 2, y_b    ), 1, Vector2i(9, 0))
				# set_cell(1, Vector2i(x_b + 2, y_b + 1), 1, Vector2i(9, 0))
			if cell.has_wall(Cell.Dir.W, mz_width, mz_height):
				set_cell(1, Vector2i(x_b - 2, y_b - 1), 1, Vector2i(9, 0))
				set_cell(1, Vector2i(x_b - 2, y_b    ), 1, Vector2i(9, 0))
				#set_cell(1, Vector2i(x_b - 2, y_b + 1), 1, Vector2i(9, 0))
			

	#for y in range(y_s, y_e):
	#	for x in range(x_s, x_e):
	#		print(x - x_s)
	#		# set_cell(int layer, Vector2i coords,
	#		#           int source_id=-1,
	#		#           Vector2i atlas_coords=Vector2i(-1, -1),
	#		#           int alternative_tile=0 )
	#		set_cell(1, Vector2i(x, y), 1, Vector2i(9, 0))

