class_name ObjectComponent extends Node

@export var FileName : String
@export var ObjectName : String

var parent
var state : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()
	parent.ready.connect(connect_parent)

func connect_parent() -> void:
	parent.connect("changed", Callable(self, "object_interacted"))

func object_interacted(states: bool) -> void:
	state = !state
	if state:
		print("Something")
		MessageBus.object_name.emit(FileName, ObjectName)
	else:
		print("Something2")
		MessageBus.object_name.emit(FileName, ObjectName)
		MessageBus.object_removed.emit(FileName)

func object_remove() -> void:
	pass
