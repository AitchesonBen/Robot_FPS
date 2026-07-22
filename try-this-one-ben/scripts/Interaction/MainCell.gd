extends Node3D

@export var Doors : Array[DoorComponent]
@export var ChargerInteraction : Node
@export var Unlocked : bool

@export var force : bool

var parent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Unlocked:
		no_lock()
		return
	MessageBus.weapon_open_door.connect(Callable(self, "forceDoor"))
	MessageBus.cell_recieved.connect(Callable(self, "unlockDoor"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func unlockDoor():
	if force:
		return
	MessageBus.unlock_door.emit(Doors)

func forceDoor():
	if force:
		MessageBus.unlock_door.emit(Doors)
		print("Cheat")

func no_lock():
	MessageBus.no_lock.emit(Doors)
