extends Node3D

@export var HITBOX : CollisionShape3D
@export var HEALTH : int

func _ready() -> void:
	MessageBus.raycastResultObject.connect(destroy_object)

func destroy_object(object: Node, damage: int) -> void:
	if object != self:
		return
	HEALTH -= damage
	print(self, "Health: ", HEALTH)
	if HEALTH <= 0:
		self.queue_free()
