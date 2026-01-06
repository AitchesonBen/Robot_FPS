class_name AnimationComponent extends Node

var target : Control
var dashed : bool = false
var dash_cooldown : float = 0.0

func _ready() -> void:
	target = get_parent()

func _process(_delta: float) -> void:
	pass

func enable_cooldown() -> void:
	dashed = Global.has_dashed
	dash_cooldown = Global.cooldown
	#print(dash_cooldown)
	if dash_cooldown > 0.0 || dashed == true:
		target.visible = true
	else:
		target.visible = false
