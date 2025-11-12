@tool

extends Node3D

@export var WEAPON_TYPE : Weapons

var weapon_instance : Node3D

func _ready() -> void:
	if not Engine.is_editor_hint():
		load_weapon()

func _input(event) -> void:
	if event.is_action_pressed("weapon1"):
		WEAPON_TYPE = load("res://model/Weapon/WeaponResources/Pistol.tres")
		load_weapon()
	if event.is_action_pressed("weapon2"):
		WEAPON_TYPE = load("res://model/Weapon/WeaponResources/AR.tres")
		load_weapon()
	if event.is_action_pressed("weapon3"):
		WEAPON_TYPE = load("res://model/Weapon/WeaponResources/Shotgun.tres")
		load_weapon()
	if event.is_action_pressed("weapon4"):
		WEAPON_TYPE = load("res://model/Weapon/WeaponResources/Sniper.tres")
		load_weapon()

func load_weapon() -> void:

	if weapon_instance and weapon_instance.is_inside_tree():
		weapon_instance.queue_free()
		weapon_instance = null
		
	if WEAPON_TYPE == null or WEAPON_TYPE.scene == null:
		return # nothing to load

	var inst = WEAPON_TYPE.scene.instantiate()
	add_child(inst)
	
	if Engine.is_editor_hint():
		inst.owner = get_tree().edited_scene_root

	inst.position = WEAPON_TYPE.position
	inst.rotation_degrees = WEAPON_TYPE.rotation

	weapon_instance = inst
