extends Unit


@onready var player = get_node("/root/Main/Player")
@onready var nav_agent = $NavigationAgent3D
@export var hp_fill: Sprite3D


func _ready() -> void:
	super()
	randomize_elements_and_shield()

func update_target_location(target_location):
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
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
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

func randomize_elements_and_shield() -> void:
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
