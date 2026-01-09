extends Area3D

@export var lifetime: float = 0.5
var lived_time = 0
var damage = 51
var type: Globals.element_type

func _physics_process(delta):
	lived_time += delta
	if lived_time > lifetime:
		queue_free()

func _on_area_entered(body):
	print("explosion hit ",body)
	if body.is_in_group("Unit"):
		body.hit(damage, type)
		#queue_free()
	if body.is_in_group("Terrain"):
		#queue_free()
		pass
