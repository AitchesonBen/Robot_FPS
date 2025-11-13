@tool

class_name WeaponController extends Node3D

@export var WEAPON_TYPE : Weapons

var weapon_instance : Node3D

@onready var weapon_pivot : Node3D = $weapon_pivot

@export var sway_noise : NoiseTexture2D
@export var sway_speed : float = 1.2
@export var reset : bool = false:
	set(value):
		reset = value
		if Engine.is_editor_hint():
			load_weapon()

var mouse_movement : Vector2
var random_sway_x
var random_sway_y
var random_sway_amount : float
var time : float = 0.0
var idle_sway_adjustment
var idle_sway_rotation_strength
var weapon_bob_amount : Vector2 = Vector2(0,0)

var jump_fall_offset: float = 0.0
var jump_fall_speed: float = 2.0  # How quickly the weapon moves to the target offset
var max_jump_offset: float = 0.3  # Max raise when jumping
var max_fall_offset: float = -0.3 # Max drop when falling
var max_offset: float = 0.3

var base_position : Vector3
var base_rotation : Vector3

func _ready() -> void:
	if not Engine.is_editor_hint():
		load_weapon()
	base_position = weapon_pivot.position
	base_rotation = weapon_pivot.rotation_degrees

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
		return

	var inst = WEAPON_TYPE.scene.instantiate()
	weapon_pivot.add_child(inst)
	
	if Engine.is_editor_hint():
		inst.owner = get_tree().edited_scene_root

	inst.position = WEAPON_TYPE.position
	inst.rotation_degrees = WEAPON_TYPE.rotation
	
	idle_sway_adjustment = WEAPON_TYPE.idle_sway_adjustment
	idle_sway_rotation_strength = WEAPON_TYPE.idle_sway_rotation_strength
	random_sway_amount = WEAPON_TYPE.random_sway_amount

	weapon_instance = inst

func sway_weapon(delta, isIdle: bool, sway_spd: float) -> void:
	if Engine.is_editor_hint():
		return
	
	mouse_movement = mouse_movement.clamp(WEAPON_TYPE.sway_min, WEAPON_TYPE.sway_max)
	
	if isIdle:
		var sway_random : float = get_sway_noise(delta)
		var sway_random_adjusted : float = sway_random * WEAPON_TYPE.idle_sway_adjustment
			
		time += delta * (sway_speed * sway_random)
		random_sway_x = sin(time * 1.5 + sway_random_adjusted) / WEAPON_TYPE.random_sway_amount
		random_sway_y = sin(time - sway_random_adjusted) / WEAPON_TYPE.random_sway_amount
		
		weapon_pivot.position.x = lerp(weapon_pivot.position.x, WEAPON_TYPE.position.x - (mouse_movement.x * WEAPON_TYPE.sway_amount_position + random_sway_x) * delta * sway_spd, WEAPON_TYPE.sway_speed_position)
		weapon_pivot.position.y = lerp(weapon_pivot.position.y, WEAPON_TYPE.position.y + (mouse_movement.y * WEAPON_TYPE.sway_amount_position + random_sway_y) * delta * sway_spd + jump_fall_offset, WEAPON_TYPE.sway_speed_position)
			
		weapon_pivot.rotation_degrees.y = lerp(weapon_pivot.rotation_degrees.y, WEAPON_TYPE.rotation.y + (mouse_movement.x * WEAPON_TYPE.sway_amount_rotation + (random_sway_y * WEAPON_TYPE.idle_sway_rotation_strength)) * delta * sway_spd, WEAPON_TYPE.sway_speed_rotation)
		weapon_pivot.rotation_degrees.x = lerp(weapon_pivot.rotation_degrees.x, WEAPON_TYPE.rotation.x - (mouse_movement.y * WEAPON_TYPE.sway_amount_rotation + (random_sway_x * WEAPON_TYPE.idle_sway_rotation_strength)) * delta * sway_spd, WEAPON_TYPE.sway_speed_rotation)

	else:
		weapon_pivot.position.x = lerp(weapon_pivot.position.x, WEAPON_TYPE.position.x - (mouse_movement.x * WEAPON_TYPE.sway_amount_position + weapon_bob_amount.x) * delta * sway_spd, WEAPON_TYPE.sway_speed_position)
		weapon_pivot.position.y = lerp(weapon_pivot.position.y, WEAPON_TYPE.position.y + (mouse_movement.y * WEAPON_TYPE.sway_amount_position + weapon_bob_amount.y) * delta * sway_spd + jump_fall_offset, WEAPON_TYPE.sway_speed_position)
			
		weapon_pivot.rotation_degrees.y = lerp(weapon_pivot.rotation_degrees.y, WEAPON_TYPE.rotation.y + (mouse_movement.x * WEAPON_TYPE.sway_amount_rotation) * delta * sway_spd, WEAPON_TYPE.sway_speed_rotation)
		weapon_pivot.rotation_degrees.x = lerp(weapon_pivot.rotation_degrees.x, WEAPON_TYPE.rotation.x - (mouse_movement.y * WEAPON_TYPE.sway_amount_rotation) * delta * sway_spd, WEAPON_TYPE.sway_speed_rotation)

func _weapon_bob(delta, bob_speed: float, hbob_amount: float, vbob_amount: float) -> void:
	time += delta
	
	weapon_bob_amount.x  = sin(time * bob_speed) * hbob_amount
	weapon_bob_amount.y = abs(cos(time * bob_speed) * vbob_amount)

func _weapon_dip(delta, player_v: float) -> void:
	var jump_target: float = 0.0
	
	if abs(player_v) > 0.01:
		jump_target = clamp(-player_v * 0.05, max_fall_offset, max_jump_offset)
	
	jump_fall_offset = lerp(jump_fall_offset, jump_target, jump_fall_speed * delta)
	
	if abs(player_v) <= 0.01:
		jump_fall_offset = lerp(jump_fall_offset, 0.0, jump_fall_speed * delta)

func _update_weapon(delta) -> void:
	jump_fall_offset = lerp(jump_fall_offset, 0.0, jump_fall_speed * delta)

func get_sway_noise(delta) -> float:
	var player_position : Vector3 = Vector3(0, 0, 0)
	
	if not Engine.is_editor_hint():
		player_position = Global.player.global_position
		
	var noise_location : float = sway_noise.noise.get_noise_2d(player_position.x, player_position.y+(delta*100))
	return noise_location
