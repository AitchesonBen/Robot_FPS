#class_name DashPlayerState extends PlayerMovementState
#
#@export var DASH_SPEED := 35.0
#@export var DASH_DECELERATION := 55.0
#@export var DASH_DURATION := 0.15
#
#var dash_timer := 0.0
#var dash_dir: Vector3
#var dash_velocity: Vector3
#
#func enter(_previous_state) -> void:
	#dash_timer = DASH_DURATION
	#PLAYER._speed = PLAYER.SPEED_DEFAULT
	#PLAYER.velocity.y = 0
	#Global.has_dashed = true
	#
	#var input_dir := Input.get_vector(
		#"move_left",
		#"move_right",
		#"move_forward",
		#"move_backward"
	#)
	#
	##dash_dir = -PLAYER.transform.basis.z
	#if input_dir.length() >= 0.1:
		#dash_dir = (PLAYER.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#else:
		#dash_dir = -PLAYER.transform.basis.z
#
	#dash_velocity = dash_dir * DASH_SPEED
	#PLAYER.velocity.x = dash_velocity.x
	#PLAYER.velocity.z = dash_velocity.z
	#
	#PLAYER.floor_snap_length = 0.8
#
#func exit() -> void:
	#pass
#
#func update(delta: float) -> void:
	#dash_timer -= delta
#
	#dash_velocity.x = move_toward(PLAYER.velocity.x, 0, DASH_DECELERATION * delta)
	#dash_velocity.z = move_toward(PLAYER.velocity.z, 0, DASH_DECELERATION * delta)
	#
	#PLAYER.velocity.x = dash_velocity.x
	#PLAYER.velocity.z = dash_velocity.z
#
	#PLAYER.update_velocity()
#
	#if dash_timer <= 0:
		#if PLAYER.velocity.y > 0.0:
			#transition.emit("FallingPlayerState")
		#else:
			#transition.emit("IdlePlayerState")


class_name DashPlayerState
extends PlayerMovementState

@export var DASH_SPEED := 35.0
@export var DASH_DECELERATION := 55.0
@export var DASH_DURATION := 0.15

var dash_timer := 0.0
var dash_direction := Vector3.ZERO
var dash_velocity := Vector3.ZERO

func enter(_previous_state) -> void:
	dash_timer = DASH_DURATION
	PLAYER._speed = PLAYER.SPEED_DEFAULT
	PLAYER.floor_snap_length = 0.8

	# Preserve vertical velocity if falling or jumping
	# If you want dash to cancel Y, set PLAYER.velocity.y = 0 instead
	PLAYER.velocity.y = 0
	var current_y_velocity = PLAYER.velocity.y

	# Get input direction
	var input_dir := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
        "move_backward"
	)

	# Determine dash direction
	if input_dir.length() >= 0.1:
		dash_direction = (PLAYER.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	else:
		# Default forward if no input
		dash_direction = -PLAYER.transform.basis.z

	dash_velocity = dash_direction * DASH_SPEED
	dash_velocity.y = current_y_velocity  # preserve vertical motion

	# Apply initial dash
	PLAYER.velocity = dash_velocity

	# Flag that player has dashed
	Global.has_dashed = true


func exit() -> void:
	# Reset anything if needed
	pass


func update(delta: float) -> void:
	dash_timer -= delta

	# Decelerate dash velocity smoothly
	dash_velocity.x = move_toward(dash_velocity.x, 0, DASH_DECELERATION * delta)
	dash_velocity.z = move_toward(dash_velocity.z, 0, DASH_DECELERATION * delta)

	# Apply dash velocity directly (ignore input)
	PLAYER.velocity.x = dash_velocity.x
	PLAYER.velocity.z = dash_velocity.z

	# Update vertical velocity with gravity or other vertical logic
	PLAYER.update_velocity()

	# Dash ends
	if dash_timer <= 0:
		# If player is falling or jumping
		if PLAYER.velocity.y > 0.0 or !PLAYER.is_on_floor():
			transition.emit("FallingPlayerState")
		else:
			transition.emit("IdlePlayerState")
