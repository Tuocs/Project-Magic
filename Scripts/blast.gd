extends Node3D

@export var speed: float = 30.0
@export var lifetime: float = 10.0
var lived_time = 0
var type: Unit.element_type

func _physics_process(delta):
	lived_time += delta
	if lived_time > lifetime:
		queue_free()
	global_position += -global_transform.basis.z.normalized() * speed * delta

func _on_area_entered(body):
	print(body)
	if body.is_in_group("Unit"):
		body.apply_knockback(position, 10)
		
func set_color(color: Color):
	var mesh_instance = $MeshInstance3D
	var material = mesh_instance.get_active_material(0)
	if material == null:
		material = StandardMaterial3D.new()
	else:
		material = material.duplicate() # Create a unique copy of the material
	material.albedo_color = color
	mesh_instance.set_surface_override_material(0, material) # Assign the unique material back
