extends Node2D

@export var ControlEnable : Node2D

func _ready() -> void:
	hide()
	get_tree().paused = false
	ControlEnable.visible = false
	$AnimationPlayer.play("RESET")

func resume():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hide()
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	ControlEnable.visible = false

func pause():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	
func restart():
	hide()
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	#get_tree().change_scene_to_file("res://Maps/ExampleLevel.tscn")
	get_tree().reload_current_scene()
	ControlEnable.visible = false
	Global.has_dashed = false

func enter_exit():
	if Input.is_action_just_pressed("exit") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("exit") and get_tree().paused:
		resume()

func _on_start_pressed() -> void:
	resume()

func _on_quit_pressed() -> void:
	hide()
	get_tree().change_scene_to_file("res://Maps/UI Scenes/Main_Menu.tscn")
	#get_tree().quit()

func _on_restart_mission_pressed() -> void:
	restart()
	
func _on_controls_pressed() -> void:
	ControlEnable.visible = true

func _process(_delta: float) -> void:
	enter_exit()
