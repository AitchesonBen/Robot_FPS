class_name DashPlayerState extends PlayerMovementState

@export var DASH_SPEED := 45.0
#Not being used
@export var DASH_DECELERATION := 55.0
@export var DASH_DURATION := 0.12
@export var DASH_REDUCER := 0.5

var dash_timer := 0.0
var dash_dir: Vector3
var dash_velocity: Vector3
#Not being used
var dash_dec

func enter(_previous_state) -> void:
	dash_timer = DASH_DURATION

	dash_dir = get_dash_direction()
	dash_dir = dash_dir.normalized()
	dash_velocity = dash_dir * DASH_SPEED

	PLAYER.velocity = dash_velocity
	
	PLAYER.floor_snap_length = 0.8

func exit() -> void:
	PLAYER.velocity *= DASH_REDUCER

func update(delta: float) -> void:
	dash_timer -= delta

	PLAYER.velocity.x = dash_velocity.x
	PLAYER.velocity.z = dash_velocity.z
	PLAYER.velocity.y = 0.0

	PLAYER.update_velocity()

	if dash_timer <= 0:
		if PLAYER.velocity.y > 0.0:
			transition.emit("FallingPlayerState")
		else:
			transition.emit("IdlePlayerState")

func get_dash_direction() -> Vector3:
	var input := Vector3.ZERO
	input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")

	if input.length() > 0.1:
		return PLAYER.global_transform.basis * input
	else:
		return -PLAYER.global_transform.basis.z
