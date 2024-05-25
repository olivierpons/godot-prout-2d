extends Node

@onready var label_score = %LabelScore
var to_collect = 0
var exit_door: Node

func _ready():
	to_collect = get_tree().get_nodes_in_group("coin").size()
	exit_door = get_tree().get_nodes_in_group("exit")[0]
	label_score.text = "Grab " + str(to_collect) + " coins!"
	
func add_point():
	to_collect -= 1
	label_score.text = "Grab " + str(to_collect) + " coin"
	if to_collect > 1:
		label_score.text += "s"
	elif to_collect == 1:
		label_score.text += "."
	else:
		label_score.text = "Find exit now!"
		exit_door.open_door()
