extends Node

var inventory_size = 2
var items = []

func _ready() -> void:
	MessageBus.weapon_name.connect(add_weapon)

func add_weapon(fileName: String, weaponName: String) -> void:
	if items.has(fileName):
		remove_weapon(fileName)
		return
	if items.size() < inventory_size - 1:
		items.append(fileName)
		Global.add_item(fileName, weaponName)
		weapon_one(fileName)
	elif items.size() < inventory_size:
		items.append(fileName)
		Global.add_item(fileName, weaponName)
		weapon_two(fileName)
	else:
		var slot = Global.current_weapon_i
		items[slot] = fileName
		Global.replace_item(slot, fileName, weaponName)
		print("Full inventory")

func weapon_one(fileName) -> void:
	print("Weapon 1: " + fileName)

func weapon_two(fileName) -> void:
	#MessageBus.full_inventory.emit(true)
	print("Weapon 2: " + fileName)

func remove_weapon(fileName: String) -> void:
	var i = items.find(fileName)
	if i == -1:
		return
	
	items.remove_at(i)
	Global.remove_item(fileName)
	
	MessageBus.weapon_removed.emit(fileName)
