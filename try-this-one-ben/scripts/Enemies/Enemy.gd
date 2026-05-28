class_name Enemy extends Node3D

enum EnemyType {walker, drone}

@export var ENEMY_TYPE : EnemyType
@export var HEALTH : int = 10
@export var DAMAGE : int = 10
@export var LIMBS : Array[Node3D]
@export var ANIMATIONPLAYER : AnimationPlayer
@export var ANIMATIONPLAYER2 : AnimationPlayer
@export var ANIMATIONPLAYER3 : AnimationPlayer

@onready var explosion = $Explosion
@export var Model : Node3D

var player : CharacterBody3D
var Collider
var availableLimbs : Array[Node3D] = LIMBS.duplicate()
var destroyedLimbs : Array[Node3D]

func _ready() -> void:
	MessageBus.raycastResult.connect(damage_taken)
	MessageBus.limbDamage.connect(limb_damage_taken)
	
func _process(_delta: float) -> void:
	if ENEMY_TYPE == EnemyType.walker:
		walker_animations()
	elif ENEMY_TYPE == EnemyType.drone:
		drone_animations()
	elif ENEMY_TYPE == null:
		pass

func initialize(_start_position):
	pass

func damage_taken(enemy: Node, _limb: Node, damage: int):
	if enemy != self:
		return
	HEALTH -= damage
	print(self, "Health: ", HEALTH)
	if HEALTH <= 0:
		if _limb == null:
			if explosion != null:
				Model.visible = false
				explosion.explode()
				await get_tree().create_timer(2.0).timeout
			get_parent().queue_free()
		else:
			if explosion != null:
				Model.visible = false
				explosion.explode()
				await get_tree().create_timer(2.0).timeout
			queue_free()

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
