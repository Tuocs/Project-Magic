extends Node
class_name My_Globals

enum spell_type {NONE, PROJECTILE, AURA, STRUCTURE, BLAST}
enum spell_mod {NONE, COLOR_RED, COLOR_YELLOW, COLOR_BLUE, COLOR_GREEN, EXTRA_CHARGE, EXTRA_DMG, EXTRA_AOE, CAST_SPREAD, REFLECT, TRAP, PUDDLE, DURATION_UP, DURATION_DOWN}
enum element_type {NONE, RED, YELLOW, BLUE, GREEN}
enum status_effect {NONE, BURN, STUN, SLOW, ROOT, HASTE}

@export var toggle_spell_window: bool = false
@export var instant_spell_cast: bool = false
@export var infinite_spell_charge: bool = false
@export var element_colors: Array[Color] = [Color(), Color(1.0, 0.0, 0.0, 1.0), Color(1.0, 1.0, 0.0, 1.0), Color(0.0, 0.0, 1.0, 1.0), Color(0.0, 1.0, 0.0, 1.0)]

static func set_color(color: Color, target: MeshInstance3D):
	var material = target.get_active_material(0)
	if material == null:
		material = StandardMaterial3D.new()
	else:
		material = material.duplicate() # Create a unique copy of the material
	if material is ShaderMaterial:
		material.set_shader_parameter("albedo_color", color)
	else:
		material.albedo_color = color
	target.material_override = null
	target.set_surface_override_material(0, material) # Assign the unique material back
	#print("origonal ", target.get_active_material(0).albedo_color, "target ", color)

func count_array_values(_array, _target_value) -> int:
	var count = 0
	for item in _array:
		if item == _target_value:
			count += 1
	return count

func get_alive_players() -> Array:
	var player_array = get_tree().get_nodes_in_group("Player")
	var alive_player_array: Array
	for player in player_array:
		if !player.is_dead:
			alive_player_array.append(player)
	return alive_player_array
