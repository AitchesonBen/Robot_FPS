extends Node3D

@export var weapons: Array[Node3D]

func _ready() -> void:
	MessageBus.weapon_name.connect(destroy)

func destroy(fileName, _weaponName) -> void:
	for weapon in weapons:
		if weapon.name == fileName:
			#weapon.visible = false
			return
