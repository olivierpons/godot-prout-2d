extends TileMap

@export var width: int = 5
@export var height: int = 4
@export var exit_door: Node2D = null
@export var coin: PackedScene = preload("res://scene/coin.tscn")

@onready var grid: Array = []

var mz_width: int
var mz_height: int

func config(c: Cell, str_link: String, str_wall: String = "") -> bool:
	for dir in str_link:
		if dir == "N" and c.has_wall(Cell.Dir.N, mz_width, mz_height):
			return false
		if dir == "E" and c.has_wall(Cell.Dir.E, mz_width, mz_height):
			return false
		if dir == "S" and c.has_wall(Cell.Dir.S, mz_width, mz_height):
			return false
		if dir == "W" and c.has_wall(Cell.Dir.W, mz_width, mz_height):
			return false
	for dir in str_wall:
		if dir == "N" and not c.has_wall(Cell.Dir.N, mz_width, mz_height):
			return false
		if dir == "E" and not c.has_wall(Cell.Dir.E, mz_width, mz_height):
			return false
		if dir == "S" and not c.has_wall(Cell.Dir.S, mz_width, mz_height):
			return false
		if dir == "W" and not c.has_wall(Cell.Dir.W, mz_width, mz_height):
			return false
	return true

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
	mz_width = int(r.size[0] / 8.0)
	mz_height = int(r.size[1] / 8.0)
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

	var _total_coins: int = 0
	for y in range(mz_height):
		for x in range(mz_width):
			var cell: Cell = mz.c(x, y)
			var x_b: int = x*4 + x_s
			var y_b: int = y*4 + y_s

			# 0, Vector2i(2, 1))
			set_cell(1, Vector2i(x_b - 2, y_b - 2), 0, Vector2i(2, 1))
			set_cell(1, Vector2i(x_b + 2, y_b - 2), 0, Vector2i(2, 1))
			set_cell(1, Vector2i(x_b - 2, y_b + 2), 0, Vector2i(2, 1))
			set_cell(1, Vector2i(x_b + 2, y_b + 2), 0, Vector2i(2, 1))

			if config(cell, "", "S"):
				set_cell(1, Vector2i(x_b - 1, y_b + 2), 1, Vector2i(11, 0))
				set_cell(1, Vector2i(x_b    , y_b + 2), 1, Vector2i(13, 0))
				set_cell(1, Vector2i(x_b + 1, y_b + 2), 1, Vector2i(14, 0))
				if (_total_coins == 0) or ((randi() % 10) == 0):
					var glob_p: Vector2i = Vector2i(x_b, y_b)
					# Make REAL pixel coords with global coords:
					glob_p = to_global(map_to_local(glob_p))
					glob_p += Vector2i(0, 18)
					var _coin: Area2D = coin.instantiate()
					_coin.delay_before_falling = -1.0
					add_child(_coin)
					_coin.global_position = glob_p
					_total_coins += 1

			# wall_s does the job, wall_n not used, manual check only for top:
			if y == 0:
				set_cell(1, Vector2i(x_b    , y_b - 2), 1, Vector2i(9, 0))
				set_cell(1, Vector2i(x_b - 1, y_b - 2), 1, Vector2i(9, 0))
				set_cell(1, Vector2i(x_b + 1, y_b - 2), 1, Vector2i(9, 0))

			if config(cell, "", "E"):
				set_cell(1, Vector2i(x_b + 2, y_b - 1), 1, Vector2i(9, 0))
				set_cell(1, Vector2i(x_b + 2, y_b    ), 1, Vector2i(9, 0))
				set_cell(1, Vector2i(x_b + 2, y_b + 1), 1, Vector2i(9, 0))
			if config(cell, "", "W"):
				set_cell(1, Vector2i(x_b - 2, y_b - 1), 1, Vector2i(9, 0))
				set_cell(1, Vector2i(x_b - 2, y_b    ), 1, Vector2i(9, 0))
				set_cell(1, Vector2i(x_b - 2, y_b + 1), 1, Vector2i(9, 0))

	# Now making it more beautiful (comment this to see original):
	for y in range(mz_height):
		for x in range(mz_width):
			var cell: Cell = mz.c(x, y)
			var x_b: int = x*4 + x_s
			var y_b: int = y*4 + y_s
			# If open W and wall S (means it's a floor):
			if config(cell, "W", "S"):
				# print("start: ", cell.pos)
				set_cell(1, Vector2i(x_b - 1, y_b + 2), 1, Vector2i(12, 0))
				set_cell(1, Vector2i(x_b - 2, y_b + 2), 1, Vector2i(13, 0))
				set_cell(1, Vector2i(x_b - 3, y_b + 2), 1, Vector2i(12, 0))
				var x_offset: int = x - 1
				var cell_offset: Cell = mz.c(x_offset, y)
				while config(cell_offset, "W", "S"):
					# +-----+-----+ 
					# | c_o  ...  |
					# +-----**----+ <= modify the (*)
					var x_w: int = cell_offset.pos.x*4 + x_s
					set_cell(1, Vector2i(x_w - 1, y_b + 2), 1, Vector2i(12, 0))
					set_cell(1, Vector2i(x_w - 2, y_b + 2), 1, Vector2i(13, 0))
					set_cell(1, Vector2i(x_w - 3, y_b + 2), 1, Vector2i(12, 0))
					# Continue to next:
					x_offset -= 1
					cell_offset = mz.c(x_offset, y)
				if not config(cell_offset, "", "S"):
					var x_w: int = cell_offset.pos.x*4 + x_s
					set_cell(1, Vector2i(x_w + 1, y_b + 2), -1, Vector2i(-1, -1))
					set_cell(1, Vector2i(x_w + 2, y_b + 2), 1, Vector2i(11, 0))
				
			#	var cell_offset: Cell = mz.c(x_offset, y)
			#	if not has_wall(cell_offset, Cell.Dir.W):
			#		if has_wall(cell_offset, Cell.Dir.S):
			#			# +-----+-----+ 
			#			# | c_o  ..P  |
			#			# +-----+-----+  <= ok, continue left
			#			continue
			#		# If here:
			#		# +-----+-----+ 
			#		# | c_o  ..P  |
			#		# +    (*)----+ <= No floor anymore modify the (*)
			#	cell_offset = mz.c(x_offset, y)
			#	if has_wall(cell, Cell.Dir.S):  # Floor
			#		
			#		if not has_wall(cell_offset, Cell.Dir.S):
			#			var x_w: int = x*4 + x_s
			#			set_cell(1, Vector2i(x_w - 2, y_b + 2), 0, Vector2i(12, 0))
			#			set_cell(1, Vector2i(x_w - 1, y_b + 2), 0, Vector2i(12, 0))
			#			set_cell(1, Vector2i(x_w + 0, y_b + 0), 0, Vector2i(13, 0))
			#			break
			#		x_offset -= 1

				#if x < (mz_width - 1) and not wall_e:
				#	var cell_e: Cell = mz.c(x + 1, y)
				#	if not has_wall(cell_e, Cell.Dir.S):
				#		# +-----+-----+
				#		# |           |
				#		# |  P        |
				#		# |           |
				#		# +----(*)    +  <= modify the (*)
				#		set_cell(1, Vector2i(x_b + 2, y_b + 2), 0, Vector2i(15, 0))
				#		if x < (mz_width - 2):
				#			var cell_e2: Cell = mz.c(x + 2, y)
				#			if not has_wall(cell_e2, Cell.Dir.S):
				#				set_cell(1, Vector2i(x_b + 1, y_b + 2), 0, Vector2i(13, 0))
				#				set_cell(1, Vector2i(x_b - 0, y_b + 0), 1, Vector2i(9, 0))

					# +-----+-----+
					# |     |     |
					# |     |  P  |
					# |     |     |
					# +-----+-----+

	#for y in range(y_s, y_e):
	#	for x in range(x_s, x_e):
	#		print(x - x_s)
	#		# set_cell(int layer, Vector2i coords,
	#		#           int source_id=-1,
	#		#           Vector2i atlas_coords=Vector2i(-1, -1),
	#		#           int alternative_tile=0 )
	#		set_cell(1, Vector2i(x, y), 1, Vector2i(9, 0))

