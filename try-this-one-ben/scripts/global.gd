extends Node

var debug
var player
var gotCell : bool = false
var double_jumped : bool = false
var has_dashed: bool = false
var cooldown : float = 0.0

var ammo : int = 10
var autoShoot : bool = false

var defaultGotCell : bool = false
var defaultDouble_jumped : bool = false
var defaultHas_dashed: bool = false
var defaultCooldown : float = 0.0

var weaponInventory: Array = []
var defaultWeaponInventory: Array = []
var current_weapon_i : int  = 0

var player_nav

func add_item(fileName: String, weaponName: String) -> void:
	weaponInventory.append({
		"file": fileName,
		"name": weaponName
	})

func replace_item(index: int, fileName: String, weaponName: String) -> void:
	var oldFile = weaponInventory[index].file
	MessageBus.weapon_removed.emit(oldFile)
	weaponInventory[index].file = fileName
	weaponInventory[index].name = weaponName

func remove_item(fileName: String) -> void:
	for i in weaponInventory.size():
		if weaponInventory[i].file == fileName:
			weaponInventory.remove_at(i)
			break

func reset():
	gotCell = defaultGotCell
	double_jumped = defaultDouble_jumped
	has_dashed = defaultHas_dashed
	cooldown = defaultCooldown
	weaponInventory = defaultWeaponInventory
