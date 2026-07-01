@tool

class_name InteractableController extends Node

@export var INTERACTABLE_OBJECT : Interactable

@onready var object_pivot : Node3D = $ObjectPivot

var object_scene : Node3D

var object_name : String = ""
var base_position : Vector3
var base_rotation : Vector3

@export var reset : bool = false:
	set(value):
		reset = value
		if Engine.is_editor_hint():
			load_object(object_name)

func _ready() -> void:
	if not Engine.is_editor_hint():
		load_object(object_name)
	base_position = object_pivot.position
	base_rotation = object_pivot.rotation_degrees
	object_name = ""
	MessageBus.object_name.connect(object_assigned)
	MessageBus.object_removed.connect(unload_object)

func object_assigned(fileName: String, objectName: String) -> void:
	var data = load("res://model/interactable/InteractableResources/" + fileName + ".tres")
	if data == null:
		push_error("Weapon data not found: " + fileName)
		return
	
	INTERACTABLE_OBJECT = data
	object_name = objectName
	
	load_object(object_name)

func load_object(name: String) -> void:
	if object_scene and object_scene.is_inside_tree():
		object_scene.queue_free()
		object_scene = null
	#unload_object()
	
	if INTERACTABLE_OBJECT == null or INTERACTABLE_OBJECT.scene == null:
		return
	
	var inst = INTERACTABLE_OBJECT.scene.instantiate()
	object_pivot.add_child(inst)

	if Engine.is_editor_hint():
		inst.owner = get_tree().edited_scene_root
	
	inst.position = INTERACTABLE_OBJECT.position
	inst.rotation_degrees = INTERACTABLE_OBJECT.rotation
	
	print("Load ", name)
	
	object_scene = inst

func unload_object(fileName: String) -> void:
	if INTERACTABLE_OBJECT == null:
		return
	INTERACTABLE_OBJECT = null
	for child in object_pivot.get_children():
		child.queue_free()

	object_scene = null
