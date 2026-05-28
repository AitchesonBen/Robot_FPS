class_name aiwalker extends CharacterBody3D

const SPEED = 4.0
const GRAVITY = 9.8

@export var speed : float = 4.0
@onready var state_chart: StateChart = $StateChart
@onready var nav_agent = $NavigationAgent3D
@export var animation_player: AnimationPlayer

var target: Node3D

var player : CharacterBody3D


func _ready() -> void:
	
	target = get_tree().get_first_node_in_group("Player")
	nav_agent.velocity_computed.connect(_on_velocity_computed)

func _physics_process(_delta: float) -> void:
	#if player == null:
		#return
	if not is_on_floor():
		velocity.y -= 20.0 * _delta
	
	#print(player.global_position)

	move_and_slide()

func on_triggered() -> void:
	state_chart.send_event("toFollow")

func initialize(_start_position):
	pass


func _on_detection_zone_body_entered(body: Node3D) -> void:
	print("Entered:", body.name)

	if body.is_in_group("Player"):
		print("Player detected")
		on_triggered()

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z

func _on_follow_state_physics_processing(delta: float) -> void:
	if not target:
		return
	
	nav_agent.target_position = target.global_position
	
	if nav_agent.is_navigation_finished():
		nav_agent.velocity = Vector3.ZERO
		return
	
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	
	nav_agent.velocity = direction * speed
	#velocity.x = direction.x * speed
	#velocity.z = direction.z * speed
	
	if direction.length() > 0.01:
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 5.0 * delta)
