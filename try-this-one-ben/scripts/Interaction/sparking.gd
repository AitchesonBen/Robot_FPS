extends Node3D

@onready var debris = $Debris

func spark() -> void:
	var t = global_transform
	reparent(get_parent().get_parent())
	global_transform = t
	debris.restart()
	debris.emitting = true
