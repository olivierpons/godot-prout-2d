class_name Maze

var _cells: Array[Cell]
var _width: int
var _height: int

func _init():
	_cells = []

func dump():
	var s: String = "".lpad(7)
	for x in range(_width):
		s += str(x).rpad(11)
	print(s)
	for y in range(_height):
		s = str(y).lpad(4) + ": "
		for x in range(_width):
			var cell: Cell = c(x, y)
			s += "(" + cell.str_links_open() + "|" + cell.str_links_wall() + ")"
		print(s)

func generate(width: int, height: int) -> void:
	_width = width
	_height = height
	
	_cells = []
	for y in range(_height):
		for x in range(_width):
			var cell: Cell = Cell.new()
			cell.pos = Vector2i(x, y)
			_cells.append(cell)

	for y in range(_height):
		for x in range(_width):
			var cell: Cell = c(x, y)
			if x > 0:
				cell.add_links_to_do(c(x - 1, y))
			if x < (width - 1):
				cell.add_links_to_do(c(x + 1, y))
			if y > 0:
				cell.add_links_to_do(c(x, y - 1))
			if y < (height - 1):
				cell.add_links_to_do(c(x, y + 1))

	var groups: Array[Array] = []
	var stack: Array[Cell] = []
	for cell in _cells:
		if cell.has_links_to_do():
			stack.append(cell)

	while stack.size() > 0:
		var rand_index: int = randi() % stack.size()
		var current_cell: Cell = stack[rand_index]
		var to_do_index: int = current_cell.get_rand_cell_to_do_index()
		if to_do_index >= 0:
			var link_to_do: Cell = current_cell.links_to_do[to_do_index]
			if current_cell.group:
				if link_to_do.group:
					if current_cell.group != link_to_do.group:
						for cell in link_to_do.group:
							current_cell.group.append(cell)
							cell.group = current_cell.group
						groups.erase(link_to_do.group)
						link_to_do.group = current_cell.group
						current_cell.move_link_to_do_as_open(link_to_do)
					else:
						current_cell.move_link_to_do_as_wall(link_to_do)
				else:
					current_cell.group.append(link_to_do)
					link_to_do.group = current_cell.group
					current_cell.move_link_to_do_as_open(link_to_do)
			else:
				if link_to_do.group:
					link_to_do.group.append(current_cell)
					current_cell.group = link_to_do.group
					link_to_do.move_link_to_do_as_open(current_cell)
				else:
					current_cell.group = [current_cell, link_to_do]
					link_to_do.group = current_cell.group
					groups.append(current_cell.group)
					current_cell.move_link_to_do_as_open(link_to_do)
			if not current_cell.has_links_to_do():
				stack.erase(current_cell)
		else:
			stack.erase(current_cell)

func c(x: int, y: int) -> Cell:
	return _cells[x + (y * _width)]
