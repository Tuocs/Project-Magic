extends Node3D

@export var speed: float = 70.0
@export var lifetime: float = 5.0
var lived_time = 0
var damage = 34
var type: Unit.element_type

func _physics_process(delta):
	lived_time += delta
	if lived_time > lifetime:
		queue_free()
	global_position += -global_transform.basis.z.normalized() * speed * delta

func _on_area_entered(body):
	print(body)
	if body.is_in_group("Unit"):
		body.hit(damage, type)
		queue_free()
	if body.is_in_group("Terrain"):
		queue_free()
