class_name WeaponComponent extends Node

@export var WeaponName : String

var parent

func _ready() -> void:
	parent = get_parent()
	parent.ready.connect(connect_parent)
	
func connect_parent() -> void:
	parent.connect("changed", Callable(self, "got_gun"))

func got_gun(state: bool) -> void:
	if state:
		MessageBus.weapon_name.emit(WeaponName)
	else:
		MessageBus.weapon_name.emit(WeaponName)
