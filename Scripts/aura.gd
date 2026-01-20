extends Node3D

@export var lingertime: float = 0.1
@export var detonatetime: float = 2.0
var active = false
var lived_time = 0
var type: Globals.element_type
var damage = 0
@onready var clear_color_target = $"Area3D/hit zone"
@onready var solid_color_target = $"warning zone"

func _process(delta: float) -> void:
	lived_time += delta
	if lived_time > detonatetime:
		$Area3D.visible = true
		$Area3D.monitoring = true
	if lived_time > detonatetime + lingertime:
		queue_free()

func _on_area_entered(body):
	print("aura hit ", body)
	if body.is_in_group("Unit"):
		body.hit(damage, type, true)
		queue_free()

func set_color(color: Color):
	var material = solid_color_target.get_active_material(0)
	if material == null:
		material = StandardMaterial3D.new()
	else:
		material = material.duplicate() # Create a unique copy of the material
	material.albedo_color = color
	solid_color_target.material_override = null
	solid_color_target.set_surface_override_material(0, material) # Assign the unique material back
	
	color.a = 0.5
	material = clear_color_target.get_active_material(0)
	if material == null:
		material = StandardMaterial3D.new()
	else:
		material = material.duplicate() # Create a unique copy of the material
	material.albedo_color = color
	clear_color_target.material_override = null
	clear_color_target.set_surface_override_material(0, material) # Assign the unique material back
