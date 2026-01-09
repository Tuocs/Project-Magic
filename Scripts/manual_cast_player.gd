extends Unit

@onready var cam = $SpringArm3D/Node3D/Camera3D
var main_ui
@export var current_magic: Globals.spell_type = Globals.spell_type.NONE
@onready var projectile_scene = preload("res://Prefabs/projectile.tscn")
@onready var blast_scene = preload("res://Prefabs/blast.tscn")
@onready var aura_scene = preload("res://Prefabs/aura.tscn")
@onready var structure_scene = preload("res://Prefabs/structure.tscn")
@export var shoot_transform_spot: Node3D
@export var shoot_rotate_spot: Node3D
@export var book_displays: Array[Node3D]
var imbuement: Globals.element_type = Globals.element_type.NONE
var spell_mods: Array[bool] = []
var ray_length: float = 1000.0 # Maximum distance of the raycast
var spell_cost: int = 1
var spell_charges: int = 0
@export var instant_cast: bool
@export var unlimited_cast: bool

func _ready():
	super()
	main_ui = $"Cast UI"
	main_ui.health_bar.value = current_health
	spell_mods.resize(Globals.spell_mod.size())
	spell_mods.fill(false)
	if instant_cast:
		main_ui.instant_cast = instant_cast

func _input(event):
	if event.is_action_pressed("edit_magic"):
		main_ui.activate()
	elif event.is_action_released("edit_magic"):
		main_ui.deactivate()
	elif event.is_action_pressed("escape"):
		esc_pause()

func _process(delta: float) -> void:
	super(delta)
	main_ui.mana_bar.value = current_mana
#region Projectile
	if Input.is_action_just_pressed("magic_cast") && !main_ui.is_active:
		if current_magic == Globals.spell_type.PROJECTILE: #-----------------------------PROJECTILE
			if current_mana < spell_cost:
				if instant_cast:
					fizzle_spell()
				return;
			current_mana -= spell_cost
			var spwn = projectile_scene.instantiate()
			add_sibling(spwn)
			var color = element_colors[imbuement]
			color.a = 0.5
			My_Globals.set_color(color, spwn.get_child(0))
			spwn.type = imbuement
			spwn.global_position = shoot_transform_spot.global_position
			spwn.transform.basis = shoot_rotate_spot.global_transform.basis
			if spell_mods[Globals.spell_mod.EXTRA_DMG]:
				spwn.damage = spwn.damage + 50
			if spell_mods[Globals.spell_mod.EXTRA_AOE]:
				spwn.aoe = true
			spell_charges -= 1
			if spell_charges <= 0:
					fizzle_spell()
#endregion
#region Aura
		if current_magic == Globals.spell_type.AURA:#-----------------------------------------AURA
			var mouse_pos: Vector2 = cam.get_viewport().get_mouse_position()
			var from: Vector3 = cam.project_ray_origin(mouse_pos)
			var to: Vector3 = from + cam.project_ray_normal(mouse_pos) * ray_length
			
			var space_state: PhysicsDirectSpaceState3D = get_world_3d().get_direct_space_state()
			var query := PhysicsRayQueryParameters3D.create(from, to)
			var result: Dictionary = space_state.intersect_ray(query)
			if result.has("position"):
				if current_mana < spell_cost:
					if instant_cast:
						fizzle_spell()
					return;
				current_mana -= spell_cost
				var hit_position: Vector3 = result["position"]
				print("Raycast hit at position: ", hit_position)
				
				var spwn = aura_scene.instantiate()
				add_sibling(spwn)
				My_Globals.set_color(element_colors[imbuement], spwn.get_child(0))
				var color = element_colors[imbuement]
				color.a = 0.5
				My_Globals.set_color(color, spwn.get_child(1).get_child(0))
				spwn.type = imbuement
				spwn.global_position = hit_position
				spwn.transform.basis = shoot_rotate_spot.get_parent().global_transform.basis
				if spell_mods[Globals.spell_mod.EXTRA_DMG]:
					spwn.damage = spwn.damage + 50
				if spell_mods[Globals.spell_mod.EXTRA_AOE]:
					spwn.scale *= 2.0
				spell_charges -= 1
				if spell_charges <= 0:
					fizzle_spell()
			else:
				print("Raycast did not hit anything.")
				if instant_cast:
					fizzle_spell()
#endregion
#region Structure
		if current_magic == Globals.spell_type.STRUCTURE:#---------------------------------Structure
			var mouse_pos: Vector2 = cam.get_viewport().get_mouse_position()
			var from: Vector3 = cam.project_ray_origin(mouse_pos)
			var to: Vector3 = from + cam.project_ray_normal(mouse_pos) * ray_length
			
			var space_state: PhysicsDirectSpaceState3D = get_world_3d().get_direct_space_state()
			var query := PhysicsRayQueryParameters3D.create(from, to)
			var result: Dictionary = space_state.intersect_ray(query)

			if result.has("position"):
				if current_mana < spell_cost:
					if instant_cast:
						fizzle_spell()
					return;
				current_mana -= spell_cost
				var hit_position: Vector3 = result["position"]
				print("Raycast hit at position: ", hit_position)
				
				var spwn = structure_scene.instantiate()
				add_sibling(spwn)
				My_Globals.set_color(element_colors[imbuement], spwn.get_child(0))
				spwn.type = imbuement
				spwn.global_position = hit_position
				spwn.transform.basis = shoot_rotate_spot.get_parent().global_transform.basis
				if spell_mods[Globals.spell_mod.EXTRA_AOE]:
					print("bigger structure")
					spwn.scale *= 2.0
				spell_charges -= 1
				if spell_charges <= 0:
					fizzle_spell()
			else:
				print("Raycast did not hit anything.")
				if instant_cast:
					fizzle_spell()
#endregion
#region Blast
		if current_magic == Globals.spell_type.BLAST:#------------------------------------BLAST
			if current_mana < spell_cost:
				if instant_cast:
					fizzle_spell()
				return;
			current_mana -= spell_cost
			var spwn = blast_scene.instantiate()
			add_sibling(spwn)
			var color = element_colors[imbuement]
			color.a = 0.5
			My_Globals.set_color(color, spwn.get_child(0))
			spwn.type = imbuement
			spwn.global_position = shoot_transform_spot.global_position
			spwn.transform.basis = shoot_rotate_spot.global_transform.basis
			if spell_mods[Globals.spell_mod.EXTRA_DMG]:
				spwn.damage = spwn.damage + 50
			if spell_mods[Globals.spell_mod.EXTRA_AOE]:
				spwn.scale *= 2.0
			spell_charges -= 1
			if spell_charges <= 0:
				fizzle_spell()
#endregion

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

func set_spell_mods(_mods: Array[bool]):
	#print(element_colors[type], current_magic, book_displays[current_magic].get_active_material(0).albedo_color)
	spell_mods = _mods.duplicate()
	print("set_spell_mods", spell_mods)
	spell_charges = 1
	if spell_mods[Globals.spell_mod.EXTRA_CHARGE]:
		spell_charges = 3
	for i in range(Globals.spell_mod.size()):
		if i < 5 && _mods[i] == true:
			imbuement = i as Globals.element_type
			My_Globals.set_color(element_colors[i], book_displays[current_magic-1])

func set_spell_type(_type: Globals.spell_type):
	book_displays[current_magic-1].visible = false
	current_magic = _type
	book_displays[current_magic-1].visible = true
	#print(element_colors[type], current_magic, book_displays[current_magic].get_active_material(0).albedo_color)

func fizzle_spell():
	print("fizzle")
	book_displays[current_magic-1].visible = false
	current_magic = Globals.spell_type.NONE
	imbuement = Globals.element_type.NONE
	spell_mods.fill(false)

func esc_pause():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://main_menu.tscn")

func update_hp():
	main_ui.health_bar.value = float(current_health)/float(max_health)

func kill():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://main_menu.tscn")
