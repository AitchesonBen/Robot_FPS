extends Node

signal interaction_focused
signal interaction_unfocused
signal cell_recieved
signal unlock_door(door: Array[DoorComponent])
signal raycastResult(enemy: Node, limb: Node)
signal limbDamage(limb: Node, damage: int)
