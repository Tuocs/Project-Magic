extends Attack

func _ready() -> void:
	clear_color_target = $MeshInstance3D
	if knockback != 0:
		knockback *= 5
	else:
		knockback = 20

func _on_area_entered(body):
	print("blast hit ",body)
	if body.is_in_group("Unit"):
		body.apply_knockback(owner_node.global_position, knockback)
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
