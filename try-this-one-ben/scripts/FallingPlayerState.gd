class_name FallingPlayerScript extends PlayerMovementState

@export var SPEED: float = 5.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25
@export var DOUBLE_JUMP_VELOCITY : float = 4.5
@export_range(0.5, 1.0, 0.01) var INPUT_MULTIPLIER : float = 0.85

var DOUBLE_JUMP : bool = false

func enter(_previous_state) -> void:
	ANIMATION.pause()

func exit() -> void:
	DOUBLE_JUMP = false

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	WEAPON.sway_weapon(delta, false, 1)
	WEAPON._weapon_dip(delta, PLAYER.velocity.y)
	
	if Input.is_action_just_pressed("jump") and DOUBLE_JUMP == false:
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
		#ANIMATION.play("JumpEnd")
		WEAPON.jump_fall_offset = lerp(WEAPON.jump_fall_offset, 0.0, WEAPON.jump_fall_speed * delta)
		transition.emit("IdlePlayerState")
