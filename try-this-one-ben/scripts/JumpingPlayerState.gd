class_name JumpingPlayerState extends PlayerMovementState

@export var SPEED: float = 10.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25
@export var JUMP_VELOCITY : float = 4.5
@export var DOUBLE_JUMP_VELOCITY : float = 4.5
@export_range(0.5, 1.0, 0.01) var INPUT_MULTIPLIER : float = 0.85

var DOUBLE_JUMP : bool = false

func enter(_previous_state) -> void:
	PLAYER.velocity.y += JUMP_VELOCITY
	ANIMATION.pause()

func exit() -> void:
	DOUBLE_JUMP = false

func update(delta) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED * INPUT_MULTIPLIER, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_pressed("jump") and DOUBLE_JUMP == false and not PLAYER.is_on_floor():
		DOUBLE_JUMP = true
		PLAYER.velocity.y = max(PLAYER.velocity.y, DOUBLE_JUMP_VELOCITY)
		var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		if input_dir.length() > 0:
			var move_dir = (PLAYER.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			var boost_vector = move_dir * PLAYER.SPEED_DEFAULT * 4.5
			PLAYER.velocity.x += boost_vector.x
			PLAYER.velocity.z += boost_vector.z
	
	if Input.is_action_just_released("jump"):
		if PLAYER.velocity.y > 0:
			PLAYER.velocity.y = PLAYER.velocity.y / 2.0
	
	if PLAYER.is_on_floor():
		transition.emit("IdlePlayerState")
		
