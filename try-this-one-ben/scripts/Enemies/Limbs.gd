class_name Limbs extends Node

@export var HITBOX : CollisionShape3D
@export var HEALTH : int

var health

func _ready() -> void:
	MessageBus.raycastResult.connect(take_damage)
	health = HEALTH

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
		self.visible = false
		if HITBOX:
			HITBOX.disabled = true
	else:
		MessageBus.limbDamage.emit(enemy, targetLimb, 1, false)
