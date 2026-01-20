extends Node
class_name My_Globals

enum spell_type {NONE, PROJECTILE, AURA, STRUCTURE, BLAST}
enum spell_mod {NONE, COLOR_RED, COLOR_YELLOW, COLOR_BLUE, COLOR_GREEN, EXTRA_CHARGE, EXTRA_DMG, EXTRA_AOE, CAST_SPREAD, REFLECT, TRAP, PUDDLE}
enum element_type {NONE, RED, YELLOW, BLUE, GREEN}

enum new_spell_type {NONE, PROJECTILE, BARRIER}
enum new_spell_mod {NONE, BARRIER_COVERAGE_FRONT, BARRIER_COVERAGE_FULL, BARRIER_COVERAGE_FOLLOW, BARRIER_EXTRA_HEALTH, BARRIER_REFLECT, PROJECTILE_PUDDLE, PROJECTILE_EXPLODE, PROJECTILE_TRAP, PROJECTILE_SHOTGUN, EXTRA_AOE, EXTRA_DAMAGE, EXTRA_DURATION, CC_PUSH, CC_STUN, CC_PULL}
@export var toggle_spell_window: bool = false
@export var instant_spell_cast: bool = false
@export var infinite_spell_charge: bool = false

static func set_color(color: Color, target: MeshInstance3D):
	var material = target.get_active_material(0)
	if material == null:
		material = StandardMaterial3D.new()
	else:
		material = material.duplicate() # Create a unique copy of the material
	material.albedo_color = color
	target.material_override = null
	target.set_surface_override_material(0, material) # Assign the unique material back
	#print("origonal ", target.get_active_material(0).albedo_color, "target ", color)
