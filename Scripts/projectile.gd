extends Node3D

@onready var explosion_scene = preload("res://Prefabs/explosion.tscn")
@export var speed: float = 70.0
@export var lifetime: float = 5.0
var lived_time = 0
var damage = 51
var type: Globals.element_type
var hostile: bool = false

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
	if hostile && body.is_in_group("Player"):
		#body.hit(damage, type)
		spawn_explosion()
		queue_free()
	if body.is_in_group("Terrain"):
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
