extends Node3D

@onready var debris = $Debris
@onready var smoke = $Smoke
@onready var smoke2 = $Smoke2
@onready var fire = $Fire

func explode() -> void:
	debris.emitting = true
	smoke.emitting = true
	fire.emitting = true
	smoke2.emitting = true
	await get_tree().create_timer(2.0).timeout
	queue_free()
