class_name CrouchingPlayerState extends PlayerMovementState

@export var SPEED : float = 4.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float  = 0.25
@export_range(1, 6, 0.1) var CROUCH_SPEED : float = 4.0
@export var WEAPON_BOB_SPD : float = 6.0
@export var WEAPON_BOB_H : float = 2.0
@export var WEAPON_BOB_V : float = 1.0

@onready var CROUCH_SHAPECAST : ShapeCast3D = $"../../ShapeCast3D"

var RELEASED : bool = false

func enter(previous_state) -> void:
	ANIMATION.speed_scale = 1.0
	if previous_state.name != "SlidingPlayerState":
		ANIMATION.play("crouch", -1.0, CROUCH_SPEED)
	elif previous_state.name == "SlidingPlayerState":
		ANIMATION.current_animation = "crouch"
		ANIMATION.seek(1.0, true)

func exit() -> void:
	RELEASED = false

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	WEAPON.sway_weapon(delta, false, 1)
	WEAPON._weapon_bob(delta, WEAPON_BOB_SPD, WEAPON_BOB_H, WEAPON_BOB_V)
	
	if Input.is_action_just_released("crouch"):
		uncrouch()
	elif Input.is_action_pressed("crouch") == false and RELEASED == false:
		RELEASED = true
		uncrouch()

func uncrouch():
	CROUCH_SHAPECAST.force_shapecast_update()
	if CROUCH_SHAPECAST.is_colliding() == false and Input.is_action_pressed("crouch") == false:
		ANIMATION.play("crouch", -1.0, -CROUCH_SPEED, true)
		if ANIMATION.is_playing():
			await ANIMATION.animation_finished
		if PLAYER.velocity.length() == 0:
			transition.emit("IdlePlayerState")
		else:
			transition.emit("WalkingPlayerState")
	elif CROUCH_SHAPECAST.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		uncrouch()
