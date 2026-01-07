extends Node2D

func _ready() -> void:
	hide()
	get_tree().paused = false
	$AnimationPlayer.play("RESET")

func resume():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hide()
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")

func pause():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	
func restart():
	hide()
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	get_tree().change_scene_to_file("res://Maps/ExampleLevel.tscn")

func test():
	if Input.is_action_just_pressed("exit") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("exit") and get_tree().paused:
		resume()

func _on_start_pressed() -> void:
	resume()

func _on_quit_pressed() -> void:
	#get_tree().change_scene_to_file("res://Maps/UI Scenes/Main_Menu.tscn")
	get_tree().quit()

func _process(_delta: float) -> void:
	test()


func _on_restart_mission_pressed() -> void:
	restart()
