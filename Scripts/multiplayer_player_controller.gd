extends "res://Scripts/player_controller.gd"


@export_category("Multiplayer Options")

func _enter_tree() -> void:
	$PlayerInput.set_multiplayer_authority(name.to_int())
	$"Cast UI".set_multiplayer_authority(name.to_int())

func _ready():
	super()
	if multiplayer.get_unique_id() == name.to_int():
		$SpringArm3D/Node3D/Camera3D.make_current()
		$"Cast UI".show()

func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		_apply_movement(delta)
