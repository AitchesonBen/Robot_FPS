class_name AmmoComponent extends CenterContainer

@export var context : Label

func _ready() -> void:
	MessageBus.ammo_count.connect(display_ammo)
	
	if MessageBus.current_weapon != "":
		display_ammo(
			MessageBus.current_weapon,
			MessageBus.ammo,
			MessageBus.ammoCap
		)

func display_ammo(name: String, ammo: int, ammoCap: int) -> void:
	var ammoList := name + " " + str(ammo) + "/" + str(ammoCap)
	context.text = ammoList
