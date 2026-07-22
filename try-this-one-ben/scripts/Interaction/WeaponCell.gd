extends Node3D

@export var Doors : Array[DoorComponent]

var parent
var stop : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()
	parent.ready.connect(connect_parent)

func connect_parent() -> void:
	parent.connect("changed", Callable(self, "unlockDoor"))
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta: float) -> void:
	pass

func unlockDoor(state: bool) -> void:
	stop = !stop
	if stop:
		MessageBus.unlock_door.emit(Doors)
		print("OIPEOPRPEOEPEN")
	else:
		print("eh")
