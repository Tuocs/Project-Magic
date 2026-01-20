extends Node3D

@export var lifetime: float = 10.0
var lived_time = 0
@onready var nav = get_node("/root/Main/NavigationRegion3D")
var type: Globals.element_type
var damage = 0
@onready var clear_color_target = $MeshInstance3D
@onready var solid_color_target = $MeshInstance3D

func _ready() -> void:
	nav.bake_navigation_mesh()

func _process(delta):
	lived_time += delta
	if lived_time > lifetime:
		position = Vector3(0,-1000,0)
		nav.bake_navigation_mesh()
		queue_free()

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
