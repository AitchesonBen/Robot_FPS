class_name SlidingPlayerState extends PlayerMovementState

@export var SPEED: float = 12.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25
@export var TILT_AMOUNT : float = 0.09
@export var SLIDE_SPEED : float = 1.25
@export_range(1, 6, 0.1) var SLIDE_ANIM_SPEED : float = 4.0

@onready var CROUCH_SHAPECAST : ShapeCast3D = $"../../CrouchShapeCast3D"

var ifJumped : bool = false

func enter(_previous_state) -> void:
	set_tilt(PLAYER._current_rotation)
	ANIMATION.get_animation("Sliding").track_set_key_value(5, 0, PLAYER.velocity.length())
	ANIMATION.speed_scale = 1.0
	ANIMATION.play("Sliding", -1.0, SLIDE_ANIM_SPEED)
	
	PLAYER.velocity.x *= SLIDE_SPEED
	PLAYER.velocity.z *= SLIDE_SPEED

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_velocity()
	
	WEAPON.sway_weapon(delta, false, 2.5)
	
	# This here is the hold to slide
	#if Input.is_action_just_released("crouch"):
		#ANIMATION.stop()
		#finish()
		
	PLAYER.velocity.x = lerp(PLAYER.velocity.x, PLAYER.velocity.x * SLIDE_SPEED, ACCELERATION * delta)
	PLAYER.velocity.z = lerp(PLAYER.velocity.z, PLAYER.velocity.z * SLIDE_SPEED, ACCELERATION * delta)
		
	if Input.is_action_just_pressed("jump"):
		ifJumped = true
		ANIMATION.stop()
		finish()
	
	if Input.is_action_just_pressed("shoot"):
		WEAPON._attack()

func set_tilt(player_rotation) -> void:
	var tilt = Vector3.ZERO
	tilt.z = clamp(TILT_AMOUNT * player_rotation, -0.1, 0.1)
	if tilt.z == 0.0:
		tilt.z = 0.05
	ANIMATION.get_animation("Sliding").track_set_key_value(3, 1, tilt)
	ANIMATION.get_animation("Sliding").track_set_key_value(3, 2, tilt)

func finish():
	if ifJumped == false:
		transition.emit("CrouchingPlayerState")
	else:
		transition.emit("JumpingPlayerState")
		ifJumped = false
