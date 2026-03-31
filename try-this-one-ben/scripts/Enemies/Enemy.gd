class_name Enemy extends Node3D

enum EnemyType {walker, drone}

@export var ENEMY_TYPE : EnemyType
@export var HEALTH : int = 10
@export var DAMAGE : int = 10
@export var LIMBS : Array[Node3D]
@export var ANIMATIONPLAYER : AnimationPlayer
@export var ANIMATIONPLAYER2 : AnimationPlayer
@export var ANIMATIONPLAYER3 : AnimationPlayer

var player = null
var Collider
var availableLimbs : Array[Node3D] = LIMBS.duplicate()
var destroyedLimbs : Array[Node3D]

func _ready() -> void:
	#player = get_node(player_path)
	MessageBus.raycastResult.connect(damage_taken)
	MessageBus.limbDamage.connect(limb_damage_taken)
	
func _process(_delta: float) -> void:
	if ENEMY_TYPE == EnemyType.walker:
		walker_animations()
		#velocity = Vector3.ZERO
		#nav_agent.set_target_position(player.global_transform.origin)
		#var next_point = nav_agent.get_next_path_position()
		#var direction = (next_point - global_transform.origin).normalized()
		#velocity = direction * 4.0
		#move_and_slide()
	elif ENEMY_TYPE == EnemyType.drone:
		drone_animations()
	elif ENEMY_TYPE == null:
		pass

func initialize(_start_position):
	#var random_speed = randi_range(10, 18)
	#velocity = Vector3.FORWARD * random_speed
	#velocity = velocity.rotated(Vector3.UP, rotation.y)
	#print("Initi")
	pass

func damage_taken(enemy: Node, _limb: Node, damage: int):
	if enemy != self:
		return
	HEALTH -= damage
	print(self, "Health: ", HEALTH)
	if HEALTH <= 0:
		self.queue_free()

func limb_damage_taken(enemy: Node, limb: Node, _damage: int, destroyed: int):
	if enemy != self:
		return
	if destroyed:
		print("Destroy")
		if limb in LIMBS:
			destroyedLimbs.append(limb)
			print("Got the limb :P")

func get_destroyed_legs() -> Array:
	var legs : Array = []
	for limb in destroyedLimbs:
		if limb.name.find("Leg") != -1:
			legs.append(limb)
	return legs

func walker_animations() -> void:
	var walker_legs = get_destroyed_legs()
	if walker_legs.size() == 1:
		ANIMATIONPLAYER.play("Missing Leg Hop")
	elif walker_legs.size() == 2:
		ANIMATIONPLAYER.stop()

func drone_animations() -> void:

	if not ANIMATIONPLAYER.is_playing():
		ANIMATIONPLAYER.play("Idle")
	if not ANIMATIONPLAYER2.is_playing():
		ANIMATIONPLAYER2.play("Constant_Hover")
	if not ANIMATIONPLAYER3.is_playing():
		ANIMATIONPLAYER3.play("Constant_Tendril_Idle")
