@tool

extends Node3D

@export var WEAPON_TYPE : Weapons

var weapon_instance : Node3D

var mouse_movement : Vector2

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
	if event is InputEventMouseMotion:
		mouse_movement = event.relative

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

func sway_weapon(delta) -> void:
	mouse_movement = mouse_movement.clamp(WEAPON_TYPE.sway_min, WEAPON_TYPE.sway_max)
	
	position.x = lerp(position.x, WEAPON_TYPE.position.x - (mouse_movement.x * WEAPON_TYPE.sway_amount_position) * delta, WEAPON_TYPE.sway_speed_position)
	position.y = lerp(position.y, WEAPON_TYPE.position.y + (mouse_movement.y * WEAPON_TYPE.sway_amount_position) * delta, WEAPON_TYPE.sway_speed_position)
	
	rotation_degrees.y = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y + (mouse_movement.x * WEAPON_TYPE.sway_amount_rotation) * delta, WEAPON_TYPE.sway_speed_rotation)
	rotation_degrees.x = lerp(rotation_degrees.x, WEAPON_TYPE.rotation.x - (mouse_movement.y * WEAPON_TYPE.sway_amount_rotation) * delta, WEAPON_TYPE.sway_speed_rotation)

func _physics_process(delta: float) -> void:
	sway_weapon(delta)
