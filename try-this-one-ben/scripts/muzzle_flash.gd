extends Node3D

#@export var weapon : WeaponController
@export var flash_time : float = 0.05

@export var light : OmniLight3D
@export var emitter : GPUParticles3D
@export var Alternate : bool

var muzzleOn : bool = self.visible

func _ready() -> void:
	MessageBus.fired.connect(add_muzzle_flash)

func add_muzzle_flash() -> void:
	if Alternate:
		if muzzleOn:
			self.visible = true
			muzzle_flash_creation()
		else:
			self.visible = false
		muzzleOn = !muzzleOn
	else:
		muzzle_flash_creation()

func muzzle_flash_creation() -> void:
	light.visible = true
	emitter.emitting = true
	await get_tree().create_timer(flash_time).timeout
	light.visible = false
