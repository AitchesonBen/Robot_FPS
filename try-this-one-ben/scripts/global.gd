extends Node

var debug
var player
var gotCell : bool = false
var double_jumped : bool = false
var has_dashed: bool = false
var cooldown : float = 0.0

var ammo : int = 10

var defaultGotCell : bool = false
var defaultDouble_jumped : bool = false
var defaultHas_dashed: bool = false
var defaultCooldown : float = 0.0

func reset():
	gotCell = defaultGotCell
	double_jumped = defaultDouble_jumped
	has_dashed = defaultHas_dashed
	cooldown = defaultCooldown
