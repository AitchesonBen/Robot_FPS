class_name Limbs extends Node

@export var HITBOX : CollisionShape3D
@export var HEALTH : int
@export var Model : Node3D
@onready var sparks = $Sparking

var health
var hitbox: Area3D

func _ready() -> void:
	MessageBus.raycastResult.connect(take_damage)
	health = HEALTH
	if HITBOX:
		HITBOX.set_meta("limb_owner", self)

func find_limb(limb: Node) -> Node:
	while limb and limb != self:
		limb = limb.get_parent()
	return limb

func take_damage(enemy: Node, limb: Node, damage: int):
	var targetLimb = find_limb(limb)
	if targetLimb != self:
		return
	health -= damage
	if health <= 0:
		print("DESTROYED ", targetLimb)
		MessageBus.limbDamage.emit(enemy, targetLimb, 1, true)
		sparks.spark()
		print(sparks)
		print(sparks.debris)
		self.visible = false
		sparks.visible = true
		if HITBOX:
			HITBOX.disabled = true
	else:
		MessageBus.limbDamage.emit(enemy, targetLimb, 1, false)
