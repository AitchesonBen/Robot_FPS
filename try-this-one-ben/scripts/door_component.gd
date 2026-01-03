class_name DoorComponent extends Area3D

enum ForwardDirection {X, Y, Z}
enum DoorOperation {MANUAL, CLOSE_AUTOMATICALLY, OPEN_CLOSE_AUTOMATICALLY}
enum DoorStatus {OPEN, CLOSED}

@export var forward_direction : ForwardDirection
@export var direction : Vector3
@export var door_size : Vector3
@export var speed : float = 0.5
@export var close_time : float = 2.0
@export var transition : Tween.TransitionType
@export var easing : Tween.EaseType
@export var door_operation : DoorOperation
#@export var close_automatically : bool = true

@onready var trigger_shape := $CollisionShape3D
#@onready var parent_door := $"../AnimatableBody3D"
var parent
var orig_pos : Vector3
var isActive : bool = false
var door_status : DoorStatus = DoorStatus.CLOSED
var door_direction : Vector3

func _ready() -> void:
	parent = get_parent()
	orig_pos = parent.position
	parent.ready.connect(connect_parent)

func _process(_delta) -> void:
	update_trigger()

func update_trigger() -> void:
	trigger_shape.disabled = not Global.chargerEquipped

func connect_parent() -> void:
	if door_operation == DoorOperation.MANUAL:
		parent.connect("interacted", Callable(self, "check_door"))

func check_door() -> void:
	print(door_status)
	match door_status:
		DoorStatus.CLOSED:
			open_door()
		DoorStatus.OPEN:
			close_door()

func open_door() -> void:
		door_status = DoorStatus.OPEN
	#if Global.chargerEquipped:
		print("open")
		var tween = get_tree().create_tween()
		tween.tween_property(parent, "position", orig_pos + (direction * door_size), speed).set_trans(transition).set_ease(easing)
		if door_operation == DoorOperation.CLOSE_AUTOMATICALLY:
			tween.tween_interval(close_time)
			tween.tween_callback(close_door)

func close_door() -> void:
	door_status = DoorStatus.CLOSED
	var tween = get_tree().create_tween()
	tween.tween_property(parent, "position", orig_pos, speed).set_trans(transition).set_ease(easing)


func _on_body_entered(body: Node3D) -> void:
	if door_operation == DoorOperation.OPEN_CLOSE_AUTOMATICALLY:
		if body is Player:
			check_door()

func _on_body_exited(body: Node3D) -> void:
	if door_operation == DoorOperation.OPEN_CLOSE_AUTOMATICALLY:
		if body is Player:
			check_door()
