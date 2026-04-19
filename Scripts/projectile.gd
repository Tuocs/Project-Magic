extends Attack

@onready var explosion_scene = preload("res://Prefabs/Spawnables/explosion.tscn")
var speed: float = 0.0
var gravity: float = 0.0
var piercing: bool = false
var sticky: bool = false
var bouncy: bool = false
var timed_explosion: bool = false
var contact_explosion: bool = false
var stuck = false
var aoe: bool = false

func _ready() -> void:
	clear_color_target = $MeshInstance3D

func _physics_process(delta):
	lived_time += delta
	if lived_time > lifetime:
		if timed_explosion:
			spawn_explosion()
		queue_free()
	global_position += -global_transform.basis.z.normalized() * speed * delta
	global_position.y -= gravity * delta

func _on_area_entered(body):
	if sticky and !stuck:
		stuck = true
		stick(body)
		return
	if body.is_in_group("Reflect") and !piercing:
		global_transform.basis.z = -global_transform.basis.z
	elif body.is_in_group("Barrier") and !piercing:
		var angle_diff = get_y_rotation_difference_3d(self, body)
		if angle_diff <= 90:
			if body.type != My_Globals.element_type.NONE:
				type = body.type
			damage += body.damage
			scale = scale*1.1
			set_color(body.clear_color_target.get_active_material(0).albedo_color)
		else:
			if contact_explosion:
				spawn_explosion()
			queue_free()
	elif body.is_in_group("Terrain"):
		if contact_explosion:
			spawn_explosion()
		queue_free()
	elif body.is_in_group("Unit") && owner_node.name != body.name:
		#body.hit(damage, type)
		if contact_explosion:
			spawn_explosion()
		if !piercing:
			queue_free()

func stick(body):
	for i in 5:
		await get_tree().create_timer(1.0).timeout
		if body.is_in_group("Unit"):
			body.hit(damage/2, type)
			body.add_status_effect(type, 5)
			if knockback != 0:
				body.apply_knockback(owner_node.global_position, knockback)
			if knockup != 0:
				body.apply_knockback(body.global_position + Vector3(0,-10,0), knockup)

func spawn_explosion():
	var spwn = explosion_scene.instantiate()
	spwn.owner_node = owner_node
	add_sibling(spwn)
	var color = $MeshInstance3D.get_active_material(0).albedo_color
	color.a = 0.5
	My_Globals.set_color(color, spwn.get_child(0))
	spwn.type = type
	spwn.damage = damage
	spwn.knockback = knockback
	spwn.global_position = global_position
	spwn.transform.basis = global_transform.basis
	if aoe:
		spwn.scale *= 2.0

func set_color(color: Color):
	color.a = 0.5
	var material = clear_color_target.get_active_material(0)
	if material == null:
		material = StandardMaterial3D.new()
	else:
		material = material.duplicate() # Create a unique copy of the material
	material.albedo_color = color
	clear_color_target.set_surface_override_material(0, material) # Assign the unique material back
	
func get_y_rotation_difference_3d(node1: Node3D, node2: Node3D) -> float:
	# Get global Y-axis rotations
	var angle1 = node1.global_rotation.y
	var angle2 = node2.global_rotation.y
	
	# Calculate the raw difference and wrap it
	var difference = angle1 - angle2
	difference = fposmod(difference + PI, TAU) - PI
	difference = abs(rad_to_deg(difference))
	return difference
