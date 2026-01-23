class_name AmmoComponent extends CenterContainer

@export var context : Label

func _ready() -> void:
	MessageBus.ammo_count.connect(display_ammo)

func display_ammo(ammo: int, ammoCap: int) -> void:
	var ammoList := str(ammo) + "/" + str(ammoCap)
	context.text = ammoList
