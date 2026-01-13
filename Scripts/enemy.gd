extends Unit


@onready var projectile_scene = preload("res://Prefabs/projectile.tscn")
@onready var player = get_node("/root/Main/Player")
@onready var nav_agent = $NavigationAgent3D
@onready var ray_cast_node = $RayCast3D
@onready var fire_rate_timer = $AttackTimer
@export var hp_fill: Sprite3D
@export var is_ranged: bool = false
@export var fire_range: float = 10
@export var fire_rate: float = 1
var can_shoot = true
var speed_mod: float = 1


func _ready() -> void:
	super()
	randomize_elements_and_shield()
	fire_rate_timer.wait_time = 1/fire_rate
	if is_ranged:
		$HatMesh.visible = true

func update_target_location(target_location):
	if is_ranged && global_position.distance_to(player.global_position) < fire_range:
		speed_mod = 0
		if is_ranged && can_shoot:
			fire_rate_timer.start()
			can_shoot = false
			var spwn = projectile_scene.instantiate()
			add_sibling(spwn)
			My_Globals.set_color(Color(1.0, 1.0, 1.0, 1.0), spwn.get_child(0))
			spwn.hostile = true
			spwn.speed = 40
			spwn.damage = 5
			spwn.global_position = global_position + Vector3(0,1.5,0)
			spwn.transform.basis = global_transform.basis
			spwn.look_at(player.global_position + Vector3(0,1.5,0))
	else:
		speed_mod = 1
		nav_agent.set_target_position(target_location)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		combine_move_and_knock(delta)
		return

	#target and move at player
	update_target_location(player.global_position)
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED * speed_mod
	
	velocity = new_velocity
	look_at(player.global_position)
	combine_move_and_knock(delta)
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("Player"):
			collider.hit(5)

func update_hp():
	hp_fill.scale.x = (float(current_health)/float(max_health))*0.4
	
func can_see_player() -> bool:
	ray_cast_node.target_position = player.global_position
	if ray_cast_node.is_colliding():
		var collider = ray_cast_node.get_collider()
		if collider == player:
			return true
	return false

func randomize_elements_and_shield() -> void:
	#set base color
	if randi_range(0,4) == 4:
		match randi_range(0,4):
			0:
				pass
			1:
				set_element_dmg_multipliers(0,1,0,0,0)
				My_Globals.set_color(Color(1.0, 0.0, 0.0, 1.0), $MeshInstance3D)
			2:
				set_element_dmg_multipliers(0,0,1,0,0)
				My_Globals.set_color(Color(1.0, 1.0, 0.0, 1.0), $MeshInstance3D)
			3:
				set_element_dmg_multipliers(0,0,0,1,0)
				My_Globals.set_color(Color(0.0, 0.0, 1.0, 1.0), $MeshInstance3D)
			4:
				set_element_dmg_multipliers(0,0,0,0,1)
				My_Globals.set_color(Color(0.0, 1.0, 0.0, 1.0), $MeshInstance3D)
		pass
	#set shield color
	if randi_range(0,4) == 4:
		match randi_range(0,4):
			0:
				pass
			1:
				give_shield(Globals.element_type.RED)
			2:
				give_shield(Globals.element_type.YELLOW)
			3:
				give_shield(Globals.element_type.BLUE)
			4:
				give_shield(Globals.element_type.GREEN)
		pass
	#set attack type
	match randi_range(0,4):
		2:
			is_ranged = true
		3:
			is_ranged = true
		4:
			is_ranged = true

func _on_attack_timer_timeout() -> void:
	can_shoot = true
