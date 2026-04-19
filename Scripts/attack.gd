extends Node3D
class_name Attack


@export var owner_node: Node3D
@export var lifetime: float = 2.0
@export var knockback: float = 0.0
@export var knockup: float = 0.0
var active = false
@export var lived_time = 0
@export var type: Globals.element_type
var spell_mods: Array
@export var damage = 0
var clear_color_target
var solid_color_target

func _ready() -> void:
	set_color(Globals.element_colors[type])

func _process(delta: float) -> void:
	lived_time += delta
	if lived_time > lifetime:
		queue_free()

func set_color(color: Color):
	color.a = 0.5
