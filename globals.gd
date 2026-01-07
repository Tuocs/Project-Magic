extends Node
class_name My_Globals

enum spell_type {NONE, PROJECTILE, AURA, STRUCTURE, BLAST}
enum spell_mod {NONE, COLOR_RED, COLOR_YELLOW, COLOR_BLUE, COLOR_GREEN}
enum element_type {NONE, RED, YELLOW, BLUE, GREEN}

static func set_color(color: Color, target: MeshInstance3D):
	var material = target.get_active_material(0)
	if material == null:
		material = StandardMaterial3D.new()
	else:
		material = material.duplicate() # Create a unique copy of the material
	material.albedo_color = color
	target.material_override = null
	target.set_surface_override_material(0, material) # Assign the unique material back
	print("origonal ", target.get_active_material(0).albedo_color, "target ", color)
