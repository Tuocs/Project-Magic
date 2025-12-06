extends Unit


@onready var player = get_node("/root/Main/Player")
@onready var nav_agent = $NavigationAgent3D


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
	combine_move_and_knock(delta)
	

func randomize_elements_and_shield() -> void:
	if randi_range(0,4) == 4:
		match randi_range(0,4):
			0:
				pass
			1:
				set_element_dmg_multipliers(0,1,0,0,0)
				set_color(Color(1.0, 0.0, 0.0, 1.0))
			2:
				set_element_dmg_multipliers(0,0,1,0,0)
				set_color(Color(1.0, 1.0, 0.0, 1.0))
			3:
				set_element_dmg_multipliers(0,0,0,1,0)
				set_color(Color(0.0, 0.0, 1.0, 1.0))
			4:
				set_element_dmg_multipliers(0,0,0,0,1)
				set_color(Color(0.0, 1.0, 0.0, 1.0))
		pass
	if randi_range(0,4) == 4:
		match randi_range(0,4):
			0:
				pass
			1:
				give_shield(element_type.RED)
			2:
				give_shield(element_type.YELLOW)
			3:
				give_shield(element_type.BLUE)
			4:
				give_shield(element_type.GREEN)
		pass
