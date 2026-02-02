extends Node3D
class_name Attack


@export var owner_name: String = "Player"
@export var lifetime: float = 2.0
var active = false
var lived_time = 0
var type: Globals.element_type
@export var damage = 0
var clear_color_target
var solid_color_target


func _process(delta: float) -> void:
	lived_time += delta
	if lived_time > lifetime:
		queue_free()
