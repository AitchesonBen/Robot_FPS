class_name SlidingPlayerState extends PlayerMovementState

@export var SPEED: float = 12.0
@export var SLOPE_SPEED : float = 8.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25
@export var TILT_AMOUNT : float = 0.09
@export var SLIDE_SPEED : float = 1.25
@export var SLIDE_DECELERATE : float = 1.1
@export_range(1, 6, 0.1) var SLIDE_ANIM_SPEED : float = 4.0
@export_range(1, 6, 0.1) var CROUCH_SPEED : float = 4.0

@onready var CROUCH_SHAPECAST : ShapeCast3D = $"../../CrouchShapeCast3D"

var ifJumped : bool = false
var is_uncrouching = false
var allow_animation_functions: bool = true
var was_on_sloop : bool = false

func enter(_previous_state) -> void:
	was_on_sloop = false
	set_tilt(PLAYER._current_rotation)
	ANIMATION.get_animation("Sliding_Intro").track_set_key_value(5, 0, PLAYER.velocity.length())
	ANIMATION.get_animation("Sliding").track_set_key_value(5, 0, PLAYER.velocity.length())
	ANIMATION.speed_scale = 1
	ANIMATION.play("Sliding_Intro", -1.0, SLIDE_ANIM_SPEED)
	if ANIMATION.is_playing():
		await ANIMATION.animation_finished
	ANIMATION.play("Sliding", -1.0, SLIDE_ANIM_SPEED)
	ANIMATION.seek(1.0, true)
	
	PLAYER.floor_snap_length = 0.8
	
	PLAYER.velocity.x *= SLIDE_SPEED
	PLAYER.velocity.z *= SLIDE_SPEED

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_velocity()
	
	WEAPON.sway_weapon(delta, false, 2.5)
	
	allow_animation_functions = not is_on_slope()
	
	#THERE WAS A ISONFLOOR CONDITION IF SOMETHING BROKE CHECK THIS
	if was_on_sloop and not is_on_slope():
		allow_animation_functions = true
		if ANIMATION.is_playing():
			await ANIMATION.animation_finished
		ANIMATION.stop()
		finish()
		
	# This here is the hold to slide
	#if Input.is_action_just_released("crouch"):
		#ANIMATION.stop()
		#finish()
	
	PLAYER.velocity.x = lerp(PLAYER.velocity.x, PLAYER.velocity.x * SLIDE_SPEED, ACCELERATION * delta)
	PLAYER.velocity.z = lerp(PLAYER.velocity.z, PLAYER.velocity.z * SLIDE_SPEED, ACCELERATION * delta)
	
	if PLAYER.is_on_floor() and is_on_slope(): 
		update_slope(delta)
		if Input.is_action_just_pressed("jump"):
			ANIMATION.play("RESET")
			allow_animation_functions = true
			ifJumped = true
			ANIMATION.stop()
			finish()
	
	was_on_sloop = is_on_slope()
	
	if Input.is_action_just_pressed("jump") and !CROUCH_SHAPECAST.is_colliding():
		ANIMATION.play("RESET")
		if !PLAYER.is_on_floor():
			Global.player.velocity.y = 0
			Global.double_jumped = true
		ifJumped = true
		ANIMATION.stop()
		finish()
	
	if PLAYER.is_on_floor():
		var hvel := Vector3(PLAYER.velocity.x, 0, PLAYER.velocity.z)
		if hvel.length() <= 0.2 and not is_on_slope() and can_stand():
			allow_animation_functions = true
			ANIMATION.stop()
			finish()
			return
	
	if PLAYER.velocity.length() > 14 and !is_on_slope():
		PLAYER.velocity /= SLIDE_DECELERATE
	elif PLAYER.velocity.length() > 18 and is_on_slope():
		PLAYER.velocity /= SLIDE_DECELERATE
	
	if Input.is_action_just_pressed("shoot") and Global.ammo > 0:
		WEAPON._attack()
	elif Input.is_action_just_pressed("shoot") and Global.ammo == 0:
		WEAPON.reload()
	
	#if PLAYER.velocity.length() <= 0.5 and !is_on_slope() and PLAYER.is_on_floor():
		#ANIMATION.stop()
		#finish()

func can_stand() -> bool:
	CROUCH_SHAPECAST.force_shapecast_update()
	return not CROUCH_SHAPECAST.is_colliding()

func set_tilt(player_rotation) -> void:
	var tilt = Vector3.ZERO
	tilt.z = clamp(TILT_AMOUNT * player_rotation, -0.1, 0.1)
	if tilt.z == 0.0:
		tilt.z = 0.05
	ANIMATION.get_animation("Sliding").track_set_key_value(3, 1, tilt)
	ANIMATION.get_animation("Sliding").track_set_key_value(3, 2, tilt)
	ANIMATION.get_animation("Sliding_Intro").track_set_key_value(3, 1, tilt)
	ANIMATION.get_animation("Sliding_Intro").track_set_key_value(3, 2, tilt)

func is_on_slope() -> bool:
	if not PLAYER.is_on_floor():
		return false

	var floor_normal = PLAYER.get_floor_normal()
	var slope_angle = rad_to_deg(acos(floor_normal.dot(Vector3.UP)))
	return slope_angle > 3
	
func update_slope(delta) -> void:
	var floor_normal = PLAYER.get_floor_normal()
	var slope_dir = floor_normal.cross(Vector3.UP).cross(floor_normal).normalized()
	
	var hvel := Vector3(PLAYER.velocity.x, 0.0, PLAYER.velocity.z)
	var uphill := hvel.dot(slope_dir) > 1.0
	
	if uphill:
		var uphill_decel = 10.0
		PLAYER.velocity -= slope_dir * SLOPE_SPEED * delta
		PLAYER.velocity -= hvel.normalized() * uphill_decel * delta
		if hvel.length() < 3.0:
			allow_animation_functions = true
			ANIMATION.stop()
			finish()
	else:
		PLAYER.velocity -= slope_dir * SLOPE_SPEED * delta

func finish():
	if not allow_animation_functions:
		return
		
	PLAYER.floor_snap_length = 0.0
		
	if ifJumped == false:
		if !can_stand():
			transition.emit("CrouchingPlayerState")
		else:
			ANIMATION.play("crouch", -1.0, -CROUCH_SPEED, true)
			await get_tree().create_timer(0.18).timeout
			transition.emit("WalkingPlayerState")
	else:
		transition.emit("JumpingPlayerState")
		ifJumped = false
