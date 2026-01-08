class_name WallRunPlayerState extends PlayerMovementState

@export var SPEED : float = 10.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float  = 0.25
@export var WEAPON_BOB_SPD : float = 6.0
@export var WEAPON_BOB_H : float = 2.0
@export var WEAPON_BOB_V : float = 1.0
@export var WALL_FALL_VELOCITY : float = 7.0

@onready var WALL_SHAPECAST : ShapeCast3D = $"../../WallShapeCast3D2"

var ifJumped : bool = false
var has_dash : bool = false

func enter(_previous_state) -> void:
	ANIMATION.play("Headbob", -1.0, 1.0)
	Global.player._speed = Global.player.SPEED_DEFAULT
	Global.player.velocity.y = 0
	Global.double_jumped = false
	Global.cooldown = 0

func exit() -> void:
	pass

func update(delta: float) -> void:
	has_dash = Global.has_dashed
	var wall_normal := WALL_SHAPECAST.get_collision_normal(0)
	PLAYER.update_wall_run_input(SPEED, ACCELERATION, DECELERATION, wall_normal)
	PLAYER.update_velocity()
	
	WEAPON.sway_weapon(delta, false, 1)
	WEAPON._weapon_bob(delta, WEAPON_BOB_SPD, WEAPON_BOB_H, WEAPON_BOB_V)
	WEAPON.jump_fall_offset = lerp(WEAPON.jump_fall_offset, 0.0, WEAPON.jump_fall_speed * delta)
	
	if Input.is_action_just_pressed("jump"):
		#WALL_SHAPECAST.enabled = false
		transition.emit("JumpingPlayerState")
		ifJumped = true
		
	if WALL_SHAPECAST.is_colliding() == false || PLAYER.velocity.length() <= WALL_FALL_VELOCITY:
		transition.emit("FallingPlayerState")
	
	if Input.is_action_just_pressed("shoot"):
		WEAPON._attack()
