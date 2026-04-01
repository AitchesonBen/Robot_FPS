class_name WeaponComponent extends Node

@export var FileName : String
@export var WeaponName : String

var original_materials := {}

var parent
var stop : bool = false

var oldFile
var oldWeapon

func _ready() -> void:
	parent = get_parent()
	parent.ready.connect(connect_parent)
	MessageBus.weapon_removed.connect(weapon_removal_color)
	
func connect_parent() -> void:
	parent.connect("changed", Callable(self, "got_gun"))

func got_gun(state: bool) -> void:
	stop = !stop
	if stop:
		MessageBus.weapon_name.emit(FileName, WeaponName)
		recolor_weapon(Color("00ffff30"))
	elif !stop:
		MessageBus.weapon_name.emit(FileName, WeaponName)
		undo_recolor()
	else:
		print("Full iventory, cant pick up")

func recolor_all_meshes(root: Node, color: Color) -> void:
	for child in root.get_children():
		if child is MeshInstance3D:
			if child.name != "MeshInstance3D":
				apply_color_preserve(child, color)
		recolor_all_meshes(child, color)

func apply_color_preserve(mesh_instance: MeshInstance3D, color: Color) -> void:
	var mesh = mesh_instance.mesh
	if mesh == null:
		return
		
	if not original_materials.has(mesh_instance):
		var mats := []
		for i in mesh.get_surface_count():
			mats.append(mesh.surface_get_material(i))
		original_materials[mesh_instance] = mats
	
	for i in mesh.get_surface_count():
		var orig_mat = mesh.surface_get_material(i)
		if orig_mat == null:
			continue
		
		var mat = orig_mat.duplicate()
		if mat is StandardMaterial3D:
			mat.albedo_color = color
			if color.a < 1.0:
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mesh_instance.set_surface_override_material(i, mat)

func recolor_weapon(color: Color) -> void:
	if owner == null:
		return
	recolor_all_meshes(owner, color)
	
func weapon_removal_color(fileName: String) -> void:
	if fileName != FileName:
		return
	
	stop = false
	undo_recolor()

func undo_recolor() -> void:
	for mesh_instance in original_materials.keys():
		var mats = original_materials[mesh_instance]
		for i in mats.size():
			mesh_instance.set_surface_override_material(i, mats[i])
	# Clear the storage so you can recolor again later
	original_materials.clear()
