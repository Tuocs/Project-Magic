extends Unit


@onready var cam = $SpringArm3D/Node3D/Camera3D
var main_ui
enum MagicMode { PROJECTILE, AURA, STRUCTURE, BLAST }
@export var current_magic: MagicMode = MagicMode.PROJECTILE
@onready var projectile_scene = preload("res://Prefabs/projectile.tscn")
@onready var blast_scene = preload("res://Prefabs/blast.tscn")
@onready var aura_scene = preload("res://Prefabs/aura.tscn")
@onready var structure_scene = preload("res://Prefabs/structure.tscn")
@export var shoot_transform_spot: Node3D
@export var shoot_rotate_spot: Node3D
@export var book_displays: Array[Node3D]
var imbuements: Array[element_type] = [element_type.NONE, element_type.NONE, element_type.NONE, element_type.NONE]
var ray_length: float = 1000.0 # Maximum distance of the raycast
var spell_cost: int = 1

func _ready():
	super()
	main_ui = $"Cast UI"

func _input(event):
	if event.is_action_pressed("edit_magic"):
		main_ui.activate()
	elif event.is_action_released("edit_magic"):
		main_ui.deactivate()

func _process(delta: float) -> void:
	super(delta)
	if Input.is_action_just_pressed("escape"):
		esc_pause()
	main_ui.mana_bar.value = current_mana
	
	#switch spell modes
	if Input.is_action_just_pressed("magic_projectile"):
		book_displays[current_magic].visible = false
		current_magic = MagicMode.PROJECTILE
		book_displays[current_magic].visible = true
	if Input.is_action_just_pressed("magic_aura"):
		book_displays[current_magic].visible = false
		current_magic = MagicMode.AURA
		book_displays[current_magic].visible = true
	if Input.is_action_just_pressed("magic_structure"):
		book_displays[current_magic].visible = false
		current_magic = MagicMode.STRUCTURE
		book_displays[current_magic].visible = true
	if Input.is_action_just_pressed("magic_blast"):
		book_displays[current_magic].visible = false
		current_magic = MagicMode.BLAST
		book_displays[current_magic].visible = true
	
	#actually cast the magic
	if Input.is_action_just_pressed("magic_cast") && !main_ui.is_active:
		if current_magic == MagicMode.PROJECTILE: #-----------------------------PROJECTILE
			if current_mana < spell_cost:
				return;
			current_mana -= spell_cost
			var spwn = projectile_scene.instantiate()
			add_sibling(spwn)
			var color = element_colors[imbuements[current_magic]]
			color.a = 0.5
			set_color(color, spwn.get_child(0))
			spwn.type = imbuements[current_magic]
			spwn.global_position = shoot_transform_spot.global_position
			spwn.transform.basis = shoot_rotate_spot.global_transform.basis
		if current_magic == MagicMode.AURA:#-----------------------------------------AURA
			var mouse_pos: Vector2 = cam.get_viewport().get_mouse_position()
			var from: Vector3 = cam.project_ray_origin(mouse_pos)
			var to: Vector3 = from + cam.project_ray_normal(mouse_pos) * ray_length
			
			var space_state: PhysicsDirectSpaceState3D = get_world_3d().get_direct_space_state()
			var query := PhysicsRayQueryParameters3D.create(from, to)
			var result: Dictionary = space_state.intersect_ray(query)

			if result.has("position"):
				if current_mana < spell_cost:
					return;
				current_mana -= spell_cost
				var hit_position: Vector3 = result["position"]
				print("Raycast hit at position: ", hit_position)
				
				var spwn = aura_scene.instantiate()
				add_sibling(spwn)
				set_color(element_colors[imbuements[current_magic]], spwn.get_child(0))
				var color = element_colors[imbuements[current_magic]]
				color.a = 0.5
				set_color(color, spwn.get_child(1).get_child(0))
				spwn.type = imbuements[current_magic]
				spwn.global_position = hit_position
				spwn.transform.basis = shoot_rotate_spot.get_parent().global_transform.basis
			else:
				print("Raycast did not hit anything.")
		if current_magic == MagicMode.STRUCTURE:#---------------------------------Structure
			var mouse_pos: Vector2 = cam.get_viewport().get_mouse_position()
			var from: Vector3 = cam.project_ray_origin(mouse_pos)
			var to: Vector3 = from + cam.project_ray_normal(mouse_pos) * ray_length
			
			var space_state: PhysicsDirectSpaceState3D = get_world_3d().get_direct_space_state()
			var query := PhysicsRayQueryParameters3D.create(from, to)
			var result: Dictionary = space_state.intersect_ray(query)

			if result.has("position"):
				if current_mana < spell_cost:
					return;
				current_mana -= spell_cost
				var hit_position: Vector3 = result["position"]
				print("Raycast hit at position: ", hit_position)
				
				var spwn = structure_scene.instantiate()
				add_sibling(spwn)
				set_color(element_colors[imbuements[current_magic]], spwn.get_child(0))
				spwn.type = imbuements[current_magic]
				spwn.global_position = hit_position
				spwn.transform.basis = shoot_rotate_spot.get_parent().global_transform.basis
			else:
				print("Raycast did not hit anything.")
		if current_magic == MagicMode.BLAST:#------------------------------------BLAST
			if current_mana < spell_cost:
				return;
			current_mana -= spell_cost
			var spwn = blast_scene.instantiate()
			add_sibling(spwn)
			var color = element_colors[imbuements[current_magic]]
			color.a = 0.5
			set_color(color, spwn.get_child(0))
			spwn.type = imbuements[current_magic]
			spwn.global_position = shoot_transform_spot.global_position
			spwn.transform.basis = shoot_rotate_spot.global_transform.basis

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	combine_move_and_knock(delta)
	
func imbue(type: element_type):
	imbuements[current_magic] = type
	#print(element_colors[type], current_magic, book_displays[current_magic].get_active_material(0).albedo_color)
	set_color(element_colors[type], book_displays[current_magic])

func esc_pause():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://main_menu.tscn")
