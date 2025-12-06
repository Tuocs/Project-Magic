extends Node3D

@export var lingertime: float = 0.1
@export var detonatetime: float = 2.0
var active = false
var lived_time = 0
var type: Unit.element_type

func _process(delta: float) -> void:
	lived_time += delta
	if lived_time > detonatetime:
		$Area3D.visible = true
		$Area3D.monitoring = true
	if lived_time > detonatetime + lingertime:
		queue_free()

func _on_area_entered(body):
	print(body)
	if body.is_in_group("Unit"):
		body.hit(0, type, true)
		queue_free()
	if body.is_in_group("Terrain"):
		queue_free()
