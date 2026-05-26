@tool

class_name WeaponController extends Node3D

signal weapon_fired

@export var WEAPON_TYPE : Weapons

enum BulletType {Bullet, Cooldown}

var weapon_scene : Node3D

var prev_ammo_count : int

@onready var weapon_pivot : Node3D = $"Recoil Position/weapon_pivot"

@export var bullet_type : BulletType

@export var sway_noise : NoiseTexture2D
@export var sway_speed : float = 1.2
@export var reset : bool = false:
	set(value):
		reset = value
		if Engine.is_editor_hint():
			load_weapon(weapon_name)

var mouse_movement : Vector2
var random_sway_x
var random_sway_y
var random_sway_amount : float
var time : float = 0.0
var idle_sway_adjustment
var idle_sway_rotation_strength
var weapon_bob_amount : Vector2 = Vector2(0,0)

var jump_fall_offset: float = 0.0
var jump_fall_speed: float = 10.0  # How quickly the weapon moves to the target offset
var max_jump_offset: float = 0.1  # Max raise when jumping
var max_fall_offset: float = -0.15 # Max drop when falling

var base_position : Vector3
var base_rotation : Vector3
var scene
var ANIMATION

var test_raycast = preload("res://raycast.tscn")

var Ammo : int
var AmmoCompacity : int
var fullAuto : bool
var rpm : float
var weapon_name : String = ""
var can_fire := true
var damage : int

var weapon_instance : WeaponInstance

func _ready() -> void:
	if not Engine.is_editor_hint():
		load_weapon(weapon_name)
	base_position = weapon_pivot.position
	base_rotation = weapon_pivot.rotation_degrees
	weapon_name = ""
	Ammo = 10
	AmmoCompacity = 10
	MessageBus.weapon_name.connect(weapon_assigned)
	MessageBus.weapon_removed.connect(unload_weapon)

func create_instance_from_inventory(entry) -> WeaponInstance:
	var data = load("res://model/Weapon/WeaponResources/" + entry.file + ".tres")
	return WeaponInstance.new(data)

func equip_weapon_from_inventory(entry) -> void:
	var data = load("res://model/Weapon/WeaponResources/" + entry.file + ".tres")

	if Global.weapon_instances.has(entry.file):
		weapon_instance = Global.weapon_instances[entry.file]
	else:
		weapon_instance = WeaponInstance.new(data)
		Global.weapon_instances[entry.file] = weapon_instance

	WEAPON_TYPE = data
	weapon_name = data.name
	
	Global.autoShoot = WEAPON_TYPE.fullAuto
	
	load_weapon(weapon_name)

func weapon_assigned(fileName: String, weaponName: String) -> void:
	var data = load("res://model/Weapon/WeaponResources/" + fileName + ".tres")
	if data == null:
		push_error("Weapon data not found: " + fileName)
		return

	# reuse instance system
	if Global.weapon_instances.has(fileName):
		weapon_instance = Global.weapon_instances[fileName]
	else:
		weapon_instance = WeaponInstance.new(data)
		Global.weapon_instances[fileName] = weapon_instance

	WEAPON_TYPE = data
	weapon_name = weaponName

	Global.autoShoot = WEAPON_TYPE.fullAuto

	load_weapon(weapon_name)

func unload_weapon(_fileName: String) -> void:
	if WEAPON_TYPE == null:
		return
	if Global.weaponInventory.size() == 0:
		WEAPON_TYPE = load("res://model/Weapon/WeaponResources/Empty.tres")
		weapon_name = "Empty"
		Global.autoShoot = WEAPON_TYPE.fullAuto
		load_weapon(weapon_name)
	else:
		equip_weapon_from_inventory(Global.weaponInventory[0])

func _input(event) -> void:
	if event.is_action_pressed("weapon1"):
		if Global.weaponInventory.size() > 0:
			#if ANIMATION.is_playing():
				#await ANIMATION.animation_finished
			var first_weapon = Global.weaponInventory[0]
			equip_weapon_from_inventory(first_weapon)
			Global.current_weapon_i = 0
			print(Global.weaponInventory)
	if event.is_action_pressed("weapon2"):
		if Global.weaponInventory.size() > 1:
			#if ANIMATION.is_playing():
				#await ANIMATION.animation_finished
			var second_weapon = Global.weaponInventory[1]
			equip_weapon_from_inventory(second_weapon)
			Global.current_weapon_i = 1
			print(Global.weaponInventory)
	if event.is_action_pressed("reload") and weapon_instance.current_ammo != weapon_instance.data.AmmoCapa:
		reload()
	if event.is_action_pressed("inspect"):
		inspect()
	if event is InputEventMouseMotion:
		mouse_movement = event.relative

func inspect() -> void:
	if ANIMATION && !ANIMATION.is_playing():
		ANIMATION.play("Inspect")

func reload() -> void:
	if ANIMATION:
		ANIMATION.play("Reload")
	if ANIMATION.is_playing():
		await ANIMATION.animation_finished
	weapon_instance.current_ammo = weapon_instance.data.AmmoCapa
	Global.ammo = weapon_instance.current_ammo
	MessageBus.ammo_count.emit(weapon_instance.data.name, weapon_instance.current_ammo, weapon_instance.data.AmmoCapa)
	can_fire = true

func load_weapon(_name: String) -> void:
	if weapon_scene and weapon_scene.is_inside_tree():
		weapon_scene.queue_free()
		weapon_scene = null
	
	if WEAPON_TYPE == null or WEAPON_TYPE.scene == null:
		return

	var inst = WEAPON_TYPE.scene.instantiate()
	weapon_pivot.add_child(inst)
	
	if Engine.is_editor_hint():
		inst.owner = get_tree().edited_scene_root
	
	ANIMATION = inst.get_node("AnimationPlayer")

	inst.position = WEAPON_TYPE.position
	inst.rotation_degrees = WEAPON_TYPE.rotation
	
	idle_sway_adjustment = WEAPON_TYPE.idle_sway_adjustment
	idle_sway_rotation_strength = WEAPON_TYPE.idle_sway_rotation_strength
	random_sway_amount = WEAPON_TYPE.random_sway_amount 
	
	AmmoCompacity = weapon_instance.data.AmmoCapa
	damage = weapon_instance.data.damage
	
	print("Load", _name)
	
	if _name != "":
		#Global.ammo = Ammo
		MessageBus.ammo_count.emit(_name, weapon_instance.current_ammo, weapon_instance.data.AmmoCapa)
	else:
		#Global.ammo = 0
		MessageBus.ammo_count.emit(_name, 0, 0)
	
	weapon_scene = inst

func _attack() -> void:
	if WEAPON_TYPE == null:
		return
	if WEAPON_TYPE.name == "Empty":
		return
	if not can_fire:
		return
	can_fire = false
	if ANIMATION.is_playing() && ANIMATION.current_animation == "Inspect":
		ANIMATION.stop()
	elif ANIMATION.is_playing():
		return
	MessageBus.fired.emit()
	weapon_fired.emit()
	var camera = Global.player.CAMERA_CONTROLLER
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().size / 2
	var origin = camera.project_ray_origin(screen_center)
	var end = origin + camera.project_ray_normal(screen_center) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	
	weapon_instance.current_ammo -= 1
	Global.ammo = weapon_instance.current_ammo
	
	MessageBus.ammo_count.emit(weapon_name, weapon_instance.current_ammo, weapon_instance.data.AmmoCapa)
	
	if result:
		raycast(result.get("position"), result.get("normal"))
		var node = result.get("collider")
		var enemy = node.get_parent()
		var object = node.get_parent()
		var limbMesh = enemy.get_parent()
		#var limb = limbMesh.get_parent()
		while enemy and not enemy.is_in_group("Enemy"):
			enemy = enemy.get_parent()
		while object and not object.is_in_group("DestructableObject"):
			object = object.get_parent()
		if enemy:
			MessageBus.raycastResult.emit(enemy, limbMesh, damage)
		elif object:
			MessageBus.raycastResultObject.emit(object, damage)
	
	var timer = round_per_minute()
	if ANIMATION.has_animation("Shoot"):
		var shootAnimation = ANIMATION.get_animation("Shoot")
		if shootAnimation:
			var length = shootAnimation.length
			var speed_scale = length / timer
			ANIMATION.speed_scale = speed_scale
			ANIMATION.stop()
			ANIMATION.play("Shoot")
	await get_tree().create_timer(timer).timeout
	can_fire = true
		#await get_tree().create_timer(timer).timeout
		#can_fire = true

func round_per_minute() -> float:
	var seconds = 60.0
	rpm = WEAPON_TYPE.rpm
	var timePerBullet = seconds / rpm
	return timePerBullet

func raycast(positionRC: Vector3, normal: Vector3) -> void:
	var instance = test_raycast.instantiate()
	get_tree().root.add_child(instance)
	instance.global_position = positionRC
	instance.look_at(instance.global_transform.origin + normal, Vector3.UP)
	instance.rotate_object_local(Vector3(1, 0, 0), 90)
	#instance.scale *= 2  <-- To increase size of decal based on damage later
	await get_tree().create_timer(10).timeout
	var fade = get_tree().create_tween()
	fade.tween_property(instance, "modulate:a", 0, 5)
	await get_tree().create_timer(5).timeout
	instance.queue_free()

func sway_weapon(delta, isIdle: bool, sway_spd: float) -> void:
	if Engine.is_editor_hint():
		return
	if WEAPON_TYPE == null:
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
