class_name Limbs extends Node

@export var LIMBS : Array[Node3D]
@export var HEALTH : int

func _ready() -> void:
	MessageBus.limbDamage.connect(take_damage)

func _process(_delta: float) -> void:
	#limb_lost()
	pass

func limb_lost() -> void:
	if HEALTH <= 0:
		pass

func take_damage(limb: Node, damage: int):
	if limb != self:
		return
	HEALTH -= damage
	print(limb, "Limb Health: ", HEALTH)
	#for LIMBS:
		#if HEALTH <= 0:
			#LIMBS.visible = false
