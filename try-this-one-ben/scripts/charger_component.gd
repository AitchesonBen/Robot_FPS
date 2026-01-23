class_name ChargerComponent extends Node

@export var Cell : Node3D
@export var Door : Node3D
@export var Cell_Collision : CollisionShape3D

var parent

func _ready() -> void:
	parent = get_parent()
	parent.ready.connect(connect_parent)

func connect_parent() -> void:
	parent.connect("interacted", Callable(self, "got_cell"))

func got_cell() -> void:
	if Global.gotCell:
		print("You 'put' it in")
		Cell_Collision.disabled = false
		Cell.visible = true
		Global.gotCell = false
		MessageBus.cell_recieved.emit()
