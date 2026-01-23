class_name DashPlayerState extends PlayerMovementState

@export var DASH_SPEED := 35.0
@export var DASH_DECELERATION := 55.0
@export var DASH_DURATION := 0.15

var dash_timer := 0.0

func enter(_previous_state) -> void:
	dash_timer = DASH_DURATION
	PLAYER._speed = PLAYER.SPEED_DEFAULT
	PLAYER.velocity.y = 0
	Global.has_dashed = true
	
	var input_dir := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)
	
	var dash_dir: Vector3 = -PLAYER.transform.basis.z
	if input_dir.length() > 0:
		dash_dir = (PLAYER.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	PLAYER.velocity.x = dash_dir.x * DASH_SPEED
	PLAYER.velocity.z = dash_dir.z * DASH_SPEED
	
	PLAYER.floor_snap_length = 0.8

func exit() -> void:
	pass

func update(delta: float) -> void:
	dash_timer -= delta

	PLAYER.velocity.x = move_toward(PLAYER.velocity.x, 0, DASH_DECELERATION * delta)
	PLAYER.velocity.z = move_toward(PLAYER.velocity.z, 0, DASH_DECELERATION * delta)

	PLAYER.update_velocity()

	if dash_timer <= 0:
		if PLAYER.velocity.y > 0.0:
			transition.emit("FallingPlayerState")
		else:
			transition.emit("IdlePlayerState")
