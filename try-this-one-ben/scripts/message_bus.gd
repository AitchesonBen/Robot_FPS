extends Node

signal interaction_focused
signal interaction_unfocused
signal cell_recieved
signal unlock_door(door: Array[DoorComponent])
signal no_lock(door: Array[DoorComponent])
signal raycastResult(enemy: Node, limb: Node)
signal limbDamage(enemy: Node, limb: Node, damage: int, destroyed: bool)
signal fired
signal ammo_count(name: String, ammo: int, ammoCap: int)

var current_weapon := "Pistol"
var ammo := 10
var ammoCap := 10

func set_ammo(name, a, c):
	current_weapon = name
	ammo = a
	ammoCap = c
	ammo_count.emit(name, a, c)
