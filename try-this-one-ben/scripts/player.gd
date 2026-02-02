class_name Player extends CharacterBody3D

@export var SPEED_DEFAULT : float = 5.0
@export var SPEED_CROUCH : float = 2.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float  = 0.25
@export var JUMP_VELOCITY : float = 4.5
@export var MOUSE_SENSITIVITY : float = 0.2
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Camera3D
@export var ANIMATIONPLAYER : AnimationPlayer
@export var CROUCH_SHAPECAST : Node3D
@export var WALL_SHAPECAST : Node3D
@export var WEAPON_CONTROLLER : WeaponController
@export var WALL_SPEED_BOOST : float = 1.25
@export var DASH_ANIMATION_IMAGE : Node
@export var HUD : Node
@export var DASH_IMAGE : Control

@export var Cell : Node3D

@export var DASH_COOLDOWN : float = 2.0
var dash_cooldown_timer := 0.0

var _speed : float
var _mouse_input : bool = false
var _mouse_rotation : Vector3
var _rotation_input : float
var _tilt_input : float
var _player_rotation: Vector3
var _camera_rotation: Vector3

var _current_rotation: float

var movement_lock := false

func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
		
func _update_camera(delta : float) -> void:
	_current_rotation = _rotation_input
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0
		
func _ready():
	Global.player = self
	Global.reset()
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	_speed = SPEED_DEFAULT
	
	CROUCH_SHAPECAST.add_exception($".")
	WALL_SHAPECAST.add_exception($".")

func _physics_process(delta: float) -> void:
	Global.debug.add_property("MovementSpeed", _speed, 1)
	Global.debug.add_property("Velocity", "%.2f" % velocity.length(), 2)
	Global.debug.add_property("Velocity X", "%.2f" % velocity.x, 2)
	Global.debug.add_property("Velocity Y", "%.2f" % velocity.y, 2)
	Global.debug.add_property("Velocity Z", "%.2f" % velocity.z, 2)
	
	#DASH_ANIMATION_IMAGE.enable_cooldown()
	var DASHUI = HUD.get_node("Dash_Fade")
	var DASHANIMATION = DASHUI.get_node("AnimationComponent")
	DASHANIMATION.enable_cooldown()
	
	if !movement_lock:
		_update_camera(delta)
	
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
		Global.cooldown = dash_cooldown_timer
	
	if Global.gotCell:
		Cell.visible = true
	
	if !Global.gotCell:
		Cell.visible = false
	
	if position.y <= -10:
		position = Vector3(-26, 7, -43)

func update_gravity(delta: float) -> void:
	velocity += get_gravity() * delta

#func update_input(speed: float, acceleration: float, deceleration: float) -> void:
	#if movement_lock:
		#return
	#var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#
	#if direction:
		#velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
		#velocity.z = lerp(velocity.z, direction.z * speed, acceleration)
	#else:
		#velocity.x = move_toward(velocity.x, 0, deceleration)
		#velocity.z = move_toward(velocity.z, 0, deceleration)

func update_input(speed: float, acceleration: float, deceleration: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	var desired_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	var desired_velocity := Vector3.ZERO

	if desired_dir.length() > 0.0:
		desired_velocity = desired_dir.normalized() * speed

	var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)

	if desired_velocity != Vector3.ZERO:
		horizontal_velocity = horizontal_velocity.lerp(desired_velocity, acceleration)
	else:
		horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, deceleration)

	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z


func update_wall_run_input(speed: float, acceleration: float, deceleration: float, wall_normal: Vector3) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	if input_dir.length() == 0:
		velocity.x = move_toward(velocity.x, 0, deceleration)
		velocity.z = move_toward(velocity.z, 0, deceleration)
		return
	
	var wish_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var wall_dir := wish_dir.slide(wall_normal).normalized()

	velocity.x = lerp(velocity.x, wall_dir.x * speed * WALL_SPEED_BOOST, acceleration)
	velocity.z = lerp(velocity.z, wall_dir.z * speed * WALL_SPEED_BOOST, acceleration)

	var push := velocity.dot(wall_normal)
	if push > 0:
		velocity -= wall_normal * push

func can_dash() -> bool:
	return dash_cooldown_timer <= 0.0
	
func start_dash_cooldown() -> void:
	dash_cooldown_timer = DASH_COOLDOWN

func update_velocity() -> void:
	move_and_slide()
