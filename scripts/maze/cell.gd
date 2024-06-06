class_name Cell

enum Dir { N, E, S, W, }

var pos: Vector2i = Vector2i(-1, -1)
var group: Array[Cell]
var links_to_do: Array[Cell]
var links_open: Array[Cell]
var links_wall: Array[Cell]

func _init():
	links_to_do = []
	links_open = []
	links_wall = []

func add_links_to_do(cell: Cell):
	links_to_do.append(cell)

func move_link_to_do_as_wall(cell: Cell):
	links_to_do.erase(cell)
	links_wall.append(cell)
	cell.links_to_do.erase(self)
	cell.links_wall.append(self)

func move_link_to_do_as_open(cell: Cell):
	links_to_do.erase(cell)
	links_open.append(cell)
	cell.links_to_do.erase(self)
	cell.links_open.append(self)

func has_links_to_do() -> bool:
	return links_to_do.size() > 0

func has_link(links:Array[Cell], v_to_find: Vector2i) -> bool:
	for cell in links:
		if self.pos - cell.pos == v_to_find:
			return true
	return false

func has_open(d: Dir) -> bool:
	if d == Dir.N:
		if pos.y == 0:
			return false
		return has_link(links_open, Vector2i(0, 1))
	elif d == Dir.E:
		return has_link(links_open, Vector2i(-1, 0))
	elif d == Dir.S:
		return has_link(links_open, Vector2i(0, -1))
	elif d == Dir.W:
		if pos.x == 0:
			return false
		return has_link(links_open, Vector2i(1, 0))
	return false

func has_wall(d: Dir) -> bool:
	if d == Dir.N:
		if pos.y == 0:
			return true
		return has_link(links_wall, Vector2i(0, 1))
	elif d == Dir.E:
		return has_link(links_wall, Vector2i(-1, 0))
	elif d == Dir.S:
		return has_link(links_wall, Vector2i(0, -1))
	elif d == Dir.W:
		if pos.x == 0:
			return true
		return has_link(links_wall, Vector2i(1, 0))
	return false
	
func str_links_open() -> String:
	var result: String = ""
	if has_open(Cell.Dir.N):
		result += "N"
	if has_open(Cell.Dir.E):
		result += "E"
	if has_open(Cell.Dir.S):
		result += "S"
	if has_open(Cell.Dir.W):
		result += "W"
	return result.lpad(4)

func str_links_wall() -> String:
	var result: String = ""
	if has_wall(Cell.Dir.N):
		result += "N"
	if has_wall(Cell.Dir.E):
		result += "E"
	if has_wall(Cell.Dir.S):
		result += "S"
	if has_wall(Cell.Dir.W):
		result += "W"
	return result.lpad(4)

func set_to_group(_group: Array[Cell]) -> void:
	group = _group

func get_rand_cell_to_do_index() -> int:
	if links_to_do.size() > 0:
		return randi() % links_to_do.size()
	return -1
