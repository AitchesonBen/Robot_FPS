class_name Enemy extends Node

@export var HEALTH : int = 10
@export var DAMAGE : int = 10
@export var LIMBS : Array[Node3D]

var Collider

func _ready() -> void:
	MessageBus.raycastResult.connect(damage_taken)

func damage_taken(enemy: Node, limb: Node):
	if enemy != self:
		return
		
	HEALTH -= 1
	MessageBus.limbDamage.emit(limb, 1)
	print(self, "Health: ", HEALTH)
	#print("Limb hit: ", limb)
