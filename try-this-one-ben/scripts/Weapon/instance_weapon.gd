class_name WeaponInstance extends RefCounted

var data : Weapons

var current_ammo : int
var fullAuto : bool
var rpm : float
var damage : int

enum BulletType {Bullet, Cooldown}

func _init(weapon_data : Weapons) -> void:
	data = weapon_data
	
	current_ammo = data.AmmoCapa
