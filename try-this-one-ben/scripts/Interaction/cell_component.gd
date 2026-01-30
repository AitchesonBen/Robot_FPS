class_name CellComponent extends Node

var parent

func _ready() -> void:
	parent = get_parent()
	parent.ready.connect(connect_parent)
	
func connect_parent() -> void:
	parent.connect("changed", Callable(self, "pick_up_cell"))

func pick_up_cell(state: bool) -> void:
	if state:
		print("Picked")
		Global.gotCell = true
		
	else:
		print("Unpicked")
		Global.gotCell = false
