class_name ChargerComponent extends Node

@export var Cell : Node3D

var parent

func _ready() -> void:
	parent = get_parent()
	parent.ready.connect(connect_parent)

func connect_parent() -> void:
	parent.connect("interacted", Callable(self, "got_cell"))

func got_cell() -> void:
	if Global.gotCell:
		print("You 'put' it in")
		Global.chargerEquipped = true
		Cell.visible = true
		Global.gotCell = false
