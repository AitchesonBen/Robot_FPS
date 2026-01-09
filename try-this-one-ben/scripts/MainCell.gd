extends Node3D

@export var Doors : Array[DoorComponent]
@export var ChargerInteraction : Node

var parent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#parent = get_parent()
	MessageBus.cell_recieved.connect(Callable(self, "unlockDoor"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func unlockDoor():
	MessageBus.unlock_door.emit(Doors)
