class_name DashPlayerState extends PlayerMovementState

@export var DASH_SPEED := 35.0
@export var DASH_DECELERATION := 55.0
@export var DASH_DURATION := 0.15

var dash_timer := 0.0

var has_dash = false

func enter(_previous_state) -> void:
	dash_timer = DASH_DURATION
	Global.player._speed = Global.player.SPEED_DEFAULT
	Global.player.velocity.y = 0
	Global.has_dashed = true
	
	var input_dir := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)
	
	var dash_dir: Vector3 = -Global.player.transform.basis.z
	if input_dir.length() > 0:
		dash_dir = (Global.player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Apply instant boost
	Global.player.velocity.x = dash_dir.x * DASH_SPEED
	Global.player.velocity.z = dash_dir.z * DASH_SPEED

func exit() -> void:
	pass

func update(delta: float) -> void:
	dash_timer -= delta

	# Strong deceleration
	Global.player.velocity.x = move_toward(Global.player.velocity.x, 0, DASH_DECELERATION * delta)
	Global.player.velocity.z = move_toward(Global.player.velocity.z, 0, DASH_DECELERATION * delta)

	Global.player.update_velocity()

	if dash_timer <= 0:
		if Global.player.velocity.y > 0.0:
			transition.emit("FallingPlayerState")
		else:
			transition.emit("IdlePlayerState")
