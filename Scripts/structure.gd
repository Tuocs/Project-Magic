extends Node3D

@export var lifetime: float = 10.0
var lived_time = 0
@onready var nav = get_node("/root/Main/NavigationRegion3D")
var type: Unit.element_type

func _ready() -> void:
	nav.bake_navigation_mesh()

func _process(delta):
	lived_time += delta
	if lived_time > lifetime:
		position = Vector3(0,-1000,0)
		nav.bake_navigation_mesh()
		queue_free()

func set_color(color: Color):
	var mesh_instance = $MeshInstance3D
	var material = mesh_instance.get_active_material(0)
	if material == null:
		material = StandardMaterial3D.new()
	else:
		material = material.duplicate() # Create a unique copy of the material
	material.albedo_color = color
	mesh_instance.set_surface_override_material(0, material) # Assign the unique material back
