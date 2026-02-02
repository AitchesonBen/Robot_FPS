class_name InteractionComponent extends Node

@export var mesh : MeshInstance3D
@export var context : String
@export var override_icon : bool
@export var new_icon : Texture2D

var parent
var highlight = preload("res://ui/Textures/interactable_highlight.tres")
var isActive : bool = false

func _ready() -> void:
	parent = get_parent()
	connect_parent()
	set_default_mesh()

func in_range() -> void:
	#mesh.material_overlay = highlight
	MessageBus.interaction_focused.emit(context, new_icon, override_icon)
	#print(parent)

func not_in_range() -> void:
	#mesh.material_overlay = null
	MessageBus.interaction_unfocused.emit()

func on_interact() -> void:
	isActive = !isActive
	print(parent.name)
	parent.emit_signal("changed", isActive)

func connect_parent() -> void:
	parent.add_user_signal("focused")
	parent.add_user_signal("unfocused")
	parent.add_user_signal("interacted")
	parent.add_user_signal("changed", ['state'])
	parent.connect("focused", Callable(self, "in_range"))
	parent.connect("unfocused", Callable(self, "not_in_range"))
	parent.connect("interacted", Callable(self, "on_interact"))

func set_default_mesh() -> void:
	if mesh:
		pass
	else:
		for i in parent.get_children():
			if i is MeshInstance3D:
				mesh = i
