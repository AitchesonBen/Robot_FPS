class_name ChargerComponent extends Node

@export var Cell : Node3D
@export var Door : Node3D
@export var Cell_Collision : CollisionShape3D

var parent

var file

func _ready() -> void:
	parent = get_parent()
	parent.ready.connect(connect_parent)
	MessageBus.object_name.connect(player_has_cell)

func connect_parent() -> void:
	parent.connect("interacted", Callable(self, "got_cell"))

func got_cell() -> void:
	if player_has_cell:
		print("You 'put' it in")
		Cell_Collision.disabled = false
		Cell.visible = true
		MessageBus.cell_recieved.emit()
		MessageBus.object_removed.emit(file)

func player_has_cell(fileName: String, objectName: String) -> bool:
	if objectName == "PowerCell":
		file = fileName
		return true
	else:
		return false
