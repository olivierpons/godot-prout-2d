extends TileMap

@export var width: int = 5
@export var height: int = 4

@onready var grid: Array = []

func _ready():
	randomize()
	# show an array of all cells of a layer! print(get_used_cells(1))
	# print dimensions of the whole TileMap! print(get_used_rect())
	var r: Rect2i = get_used_rect()
	print(r, " / ", r.position, " / ", r.end)
	var x_s: int = r.position[0]
	var y_s: int = r.position[1]
	var x_e: int = r.end[0]
	var y_e: int = r.end[1]
	var mz: Maze = Maze.new()
	print(r.size[0], "/", r.size[1])
	var mz_width: int = int(r.size[0] / 3)
	var mz_height: int = int(r.size[1] / 3)
	mz_width = 4
	mz_height = 3
	mz.generate(mz_width, mz_height)
	mz.dump()
	for y in range(mz_height):
		for x in range(mz_width):
			var cell: Cell = mz.c(x, y)
			set_cell(1, Vector2i(x*2 + x_s - 1, y*2 + y_s - 1), 1, Vector2i(9, 0))
			set_cell(1, Vector2i(x*2 + x_s + 1, y*2 + y_s - 1), 1, Vector2i(9, 0))
			set_cell(1, Vector2i(x*2 + x_s - 1, y*2 + y_s + 1), 1, Vector2i(9, 0))
			set_cell(1, Vector2i(x*2 + x_s + 1, y*2 + y_s + 1), 1, Vector2i(9, 0))
			if cell.has_wall(Cell.Dir.N):
				set_cell(1, Vector2i(x*2 + x_s, y*2 + y_s - 1), 1, Vector2i(9, 0))
			if cell.has_wall(Cell.Dir.S):
				set_cell(1, Vector2i(x*2 + x_s, y*2 + y_s + 1), 1, Vector2i(9, 0))
			if cell.has_wall(Cell.Dir.E):
				set_cell(1, Vector2i(x*2 + x_s + 1, y*2 + y_s), 1, Vector2i(9, 0))
			if cell.has_wall(Cell.Dir.W):
				set_cell(1, Vector2i(x*2 + x_s - 1, y*2 + y_s), 1, Vector2i(9, 0))
			

	#for y in range(y_s, y_e):
	#	for x in range(x_s, x_e):
	#		print(x - x_s)
	#		# set_cell(int layer, Vector2i coords,
	#		#           int source_id=-1,
	#		#           Vector2i atlas_coords=Vector2i(-1, -1),
	#		#           int alternative_tile=0 )
	#		set_cell(1, Vector2i(x, y), 1, Vector2i(9, 0))

