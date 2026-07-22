@tool

extends Node3D

@export var WEAPON_ATTACH : PackedScene

var weapon : Node3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if WEAPON_ATTACH:
		weapon = WEAPON_ATTACH.instantiate()
		add_child(weapon)
