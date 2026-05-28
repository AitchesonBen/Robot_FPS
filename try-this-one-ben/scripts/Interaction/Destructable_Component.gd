extends Node3D

@onready var explosion = $Explosion
@export var HITBOX : CollisionShape3D
@export var HEALTH : int
@export var Model : Node3D

func _ready() -> void:
	MessageBus.raycastResultObject.connect(destroy_object)

func destroy_object(object: Node, damage: int) -> void:
	if object != self:
		return
	HEALTH -= damage
	print(self, "Health: ", HEALTH)
	if HEALTH <= 0:
		
		Model.visible = false
		explosion.explode()
		#self.visible = false
		await get_tree().create_timer(2.0).timeout
		self.queue_free()
