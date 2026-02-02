extends Node3D

@export var enemy: PackedScene
@export var timer : Timer
@export var EnemySpawnTime: float

var currentEnemy : Node3D = null

func _ready() -> void:
	timer.wait_time = EnemySpawnTime
	timer.start()

func _on_timer_timeout() -> void:
	currentEnemy = enemy.instantiate()
	currentEnemy.initialize(get_parent().position)
	add_child(currentEnemy)
	currentEnemy.tree_exited.connect(_on_enemy_removed)
	timer.stop()

func _on_enemy_removed():
	currentEnemy = null
	timer.start()
