extends Node3D

@onready var explosion_scene = preload("res://Prefabs/explosion.tscn")
@export var speed: float = 70.0
@export var lifetime: float = 5.0
var lived_time = 0
var damage = 51
var aoe: bool = false
var type: Globals.element_type
var hostile: bool = false
@onready var clear_color_target = $MeshInstance3D
@onready var solid_color_target

func _physics_process(delta):
	lived_time += delta
	if lived_time > lifetime:
		queue_free()
	global_position += -global_transform.basis.z.normalized() * speed * delta

func _on_area_entered(body):
	print(body)
	if !hostile && body.is_in_group("Enemy"):
		#body.hit(damage, type)
		spawn_explosion()
		queue_free()
	elif hostile && body.is_in_group("Player"):
		#body.hit(damage, type)
		spawn_explosion()
		queue_free()
	if body.is_in_group("Reflect"):
		global_transform.basis.z = -global_transform.basis.z
	elif body.is_in_group("Terrain"):
		spawn_explosion()
		queue_free()

func spawn_explosion():
	var spwn = explosion_scene.instantiate()
	add_sibling(spwn)
	var color = $MeshInstance3D.get_active_material(0).albedo_color
	color.a = 0.5
	My_Globals.set_color(color, spwn.get_child(0))
	spwn.type = type
	spwn.damage = damage
	spwn.global_position = global_position
	spwn.transform.basis = global_transform.basis
	if aoe:
		spwn.scale *= 2.0

func set_color(color: Color):
	color.a = 0.5
	var mesh_instance = $MeshInstance3D
	var material = mesh_instance.get_active_material(0)
	if material == null:
		material = StandardMaterial3D.new()
	else:
		material = material.duplicate() # Create a unique copy of the material
	material.albedo_color = color
	mesh_instance.set_surface_override_material(0, material) # Assign the unique material back
