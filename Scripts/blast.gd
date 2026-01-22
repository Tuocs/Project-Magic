extends Node3D

@export var speed: float = 30.0
@export var lifetime: float = 10.0
var lived_time = 0
var type: Globals.element_type
var damage = 0
@onready var clear_color_target = $MeshInstance3D
@onready var solid_color_target

func _physics_process(delta):
	lived_time += delta
	if lived_time > lifetime:
		queue_free()
	global_position += -global_transform.basis.z.normalized() * speed * delta

func _on_area_entered(body):
	print("blast hit ",body)
	if body.is_in_group("Unit"):
		body.apply_knockback(position, 20)
		body.hit(damage, type)
		if type != Globals.element_type.NONE && body.is_in_group("Enemy"):
			body.paint_color(type)

func set_color(color: Color):
	color.a = 0.5
	var material = clear_color_target.get_active_material(0)
	if material == null:
		material = StandardMaterial3D.new()
	else:
		material = material.duplicate() # Create a unique copy of the material
	material.albedo_color = color
	clear_color_target.material_override = null
	clear_color_target.set_surface_override_material(0, material) # Assign the unique material back
