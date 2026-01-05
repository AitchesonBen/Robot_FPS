class_name WallRunPlayerState extends PlayerMovementState

@export var SPEED : float = 10.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float  = 0.25

@onready var WALL_SHAPECAST : ShapeCast3D = $"../../WallShapeCast3D2"

var ifJumped : bool = false

func enter(_previous_state) -> void:
	ANIMATION.play("Headbob", -1.0, 1.0)
	Global.player._speed = Global.player.SPEED_DEFAULT
	Global.player.velocity.y = 0
	Global.double_jumped = false

func exit() -> void:
	pass

func update(delta: float) -> void:
	var wall_normal := WALL_SHAPECAST.get_collision_normal(0)
	PLAYER.update_wall_run_input(SPEED, ACCELERATION, DECELERATION, wall_normal)
	PLAYER.update_velocity()
	
	if Input.is_action_just_pressed("jump"):
		WALL_SHAPECAST.enabled = false
		transition.emit("JumpingPlayerState")
		ifJumped = true
		
	if WALL_SHAPECAST.is_colliding() == false || PLAYER.velocity.length() == 0.0:
		transition.emit("FallingPlayerState")
	
	if Input.is_action_just_pressed("shoot"):
		WEAPON._attack()
