class_name AmmoComponent extends CenterContainer

@export var context : Label

func _ready() -> void:
	context.visible = true
	MessageBus.ammo_count.connect(display_ammo)
	MessageBus.weapon_removed.connect(update_display)
	
	if MessageBus.current_weapon != "":
		context.visible = true
		display_ammo(
			MessageBus.current_weapon,
			MessageBus.ammo,
			MessageBus.ammoCap
		)
	elif MessageBus.current_weapon == "Empty":
		context.visible = false

func display_ammo(_name: String, ammo: int, ammoCap: int) -> void:
	if _name == "":
		return
	var ammoList := _name + " " + str(ammo) + "/" + str(ammoCap)
	context.text = ammoList

func update_display() -> void:
	if MessageBus.current_weapon == "":
		context.visible = false
	elif MessageBus.current_weapon == "Empty":
		context.visible = false
