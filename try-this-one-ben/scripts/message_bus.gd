extends Node

signal interaction_focused
signal interaction_unfocused
signal cell_recieved
signal unlock_door(door: Array[DoorComponent])
signal no_lock(door: Array[DoorComponent])
signal raycastResult(enemy: Node, limb: Node)
signal limbDamage(limb: Node, damage: int)
signal fired
signal ammo_count(name: String, ammo: int, ammoCap: int)

var current_weapon := ""
var ammo := 0
var ammoCap := 0

func set_ammo(name, a, c):
	current_weapon = name
	ammo = a
	ammoCap = c
	ammo_count.emit(name, a, c)
