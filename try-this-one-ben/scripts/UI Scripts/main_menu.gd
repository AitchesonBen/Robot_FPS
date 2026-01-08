extends Node2D

@export var ControlEnable : Node2D

func _ready() -> void:
	get_tree().paused = false
	ControlEnable.visible = false

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Maps/ExampleLevel.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_controls_pressed() -> void:
	ControlEnable.visible = true
