class_name AnimationComponent extends Node

@export var mesh : MeshInstance3D

#var target : Control
var dashed : bool = false
var dash_cooldown : float = 0.0
var dash_ready_color: Color = Color("#00ffffaf")
var dash_cooldown_color: Color = Color("#b2b2b264")
var white: Color = Color('#ff0fff')

func _ready() -> void:
	#target = get_parent()
	pass

func _process(_delta: float) -> void:
	pass

func enable_cooldown() -> void:
	dashed = Global.has_dashed
	dash_cooldown = Global.cooldown
	update_color()
	#_update_shader()

func update_color() -> void:
	var mat = mesh.get_active_material(0)
	if not mat:
		return
	if dash_cooldown > 0.0 || dashed == true:
		#var t := 1.0 - (dash_cooldown / 1.5)
		#t = clamp(t, 0.0, 1.0)
		mat.albedo_color = dash_cooldown_color
	else:
		var t := 1.0
		t = clamp(t, 0.0, 0.5)
		mat.albedo_color = white.lerp(dash_ready_color, t)
		mat.albedo_color = dash_ready_color
	
func _update_shader() -> void:
	var mat := mesh.get_active_material(0) as ShaderMaterial
	if not mat:
		return

	var progress := 1.0 - (dash_cooldown / 1.5)
	mat.set_shader_parameter("progress", clamp(progress, 0.0, 1.0))
	
func on_hover() -> void:
	pass

func off_hover() -> void:
	pass
