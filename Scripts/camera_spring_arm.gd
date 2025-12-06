extends SpringArm3D

@export var mouse_sensitivity: float = 0.001
var _player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_player = get_parent_node_3d()



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_player.rotation.y -= event.relative.x * mouse_sensitivity
		_player.rotation.y = wrapf(_player.rotation.y, 0.0, TAU)
		
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation.x = clamp(rotation.x, -PI/2, PI/4)
