extends CharacterBody3D

var player : CharacterBody3D = null

@onready var nav_agent = $NavigationAgent3D

const SPEED = 4.0
const GRAVITY = 9.8


func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if player == null:
		return
	nav_agent.set_target_position(player.global_position)

func _physics_process(_delta: float) -> void:
	if player == null:
		return
		
	#velocity = Vector3.ZERO
	#nav_agent.target_position = player.global_position
	var next_point: Vector3 = nav_agent.get_next_path_position()
	#var direction = (next_point - global_position).normalized()
	#velocity = direction * SPEED
	velocity = global_position.direction_to(next_point) * SPEED
	
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	print(player.global_position)

	move_and_slide()

func initialize(_start_position):
	#var random_speed = randi_range(10, 18)
	#velocity = Vector3.FORWARD * random_speed
	#velocity = velocity.rotated(Vector3.UP, rotation.y)
	#print("Initi")
	pass
