extends Unit

@onready var cam = $SpringArm3D/Node3D/Camera3D
var cast_ui
var current_magic: Globals.spell_type = Globals.spell_type.NONE
@onready var projectile_scene = preload("res://Prefabs/Spawnables/projectile.tscn")
@onready var blast_scene = preload("res://Prefabs/Spawnables/blast.tscn")
@onready var aura_scene = preload("res://Prefabs/Spawnables/aura.tscn")
@onready var structure_scene = preload("res://Prefabs/Spawnables/structure.tscn")
@export var shoot_transform_spot: Node3D
@export var shoot_rotate_spot: Node3D
@export var book_displays: Array[Node3D]
var spread_count: int = 0
var imbuement: Globals.element_type = Globals.element_type.NONE
var spell_mods: Array[bool] = []
var ray_length: float = 1000.0 # Maximum distance of the raycast
var spell_cost: int = 1
var spell_charges: int = 0
var unlimited_cast: bool

func _ready():
	super()
	cast_ui = $"Cast UI"
	cast_ui.health_bar.value = current_health
	spell_mods.resize(Globals.spell_mod.size())
	spell_mods.fill(false)

func _input(event):
	if Globals.toggle_spell_window:
		if event.is_action_pressed("edit_magic") && cast_ui.is_active:
			cast_ui.deactivate()
		elif event.is_action_pressed("edit_magic"):
			cast_ui.activate()
	else:
		if event.is_action_released("edit_magic"):
			cast_ui.deactivate()
		elif event.is_action_pressed("edit_magic"):
			cast_ui.activate()


#region Spells
	if Input.is_action_just_pressed("magic_cast") && !cast_ui.is_active:
		if current_magic != Globals.spell_type.NONE:
			if (!base_spell_costs()):
				return
			if spell_mods[Globals.spell_mod.CAST_SPREAD]:
				spread_count = 2
		if current_magic == Globals.spell_type.PROJECTILE:
			cast_projectile()
		elif current_magic == Globals.spell_type.AURA:
			cast_aura()
		elif current_magic == Globals.spell_type.STRUCTURE:
			cast_structure()
		elif current_magic == Globals.spell_type.BLAST:
			cast_blast()
		if spell_charges <= 0:
			fizzle_spell()

func cast_projectile(inaccuracy: float = 0): #-----------------------------PROJECTILE
	var pos = shoot_transform_spot.global_position
	var rot = shoot_rotate_spot.global_transform.basis
	var spwn = base_spell_effects(projectile_scene, pos, rot)
	spwn.rotation_degrees.y += randf_range(-inaccuracy, inaccuracy)
	if spell_mods[Globals.spell_mod.EXTRA_AOE]:
		spwn.aoe = true
	if spread_count > 0:
		spread_count -= 1
		cast_projectile(30)
func cast_aura(inaccuracy: float = 0):#-----------------------------------------AURA
	var viewport_size: Vector2 = get_viewport().size
	var screen_center_pos: Vector2 = Vector2(viewport_size.x / 2.0, viewport_size.y / 2.0)
	var from: Vector3 = cam.project_ray_origin(screen_center_pos)
	var to: Vector3 = from + cam.project_ray_normal(screen_center_pos) * ray_length
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().get_direct_space_state()
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result: Dictionary = space_state.intersect_ray(query)
	if result.has("position"):
		var pos: Vector3 = result["position"]
		pos += Vector3(randf_range(-inaccuracy, inaccuracy), 0, randf_range(-inaccuracy, inaccuracy))
		var rot = shoot_rotate_spot.get_parent().global_transform.basis
		var spwn = base_spell_effects(aura_scene, pos, rot)
		if spell_mods[Globals.spell_mod.EXTRA_AOE]:
			spwn.scale *= 2.0
		if spread_count > 0:
			spread_count -= 1
			cast_aura(7)
	else:
		print("Raycast did not hit anything.")
		spread_count = 0
		if Globals.instant_spell_cast:
			fizzle_spell()
func cast_structure(inaccuracy: float = 0):#---------------------------------Structure
	var forward_direction = global_transform.basis.z.normalized()
	var pos = global_transform.origin - forward_direction.rotated(Vector3.UP, randf_range(-inaccuracy, inaccuracy)) * 6
	var rot = shoot_rotate_spot.get_parent().global_transform.basis
	var spwn = base_spell_effects(structure_scene, pos, rot)
	if spell_mods[Globals.spell_mod.EXTRA_AOE]:
		spwn.scale *= 2.0
	if spread_count > 0:
		spread_count -= 1
		cast_structure(60)
func cast_blast(inaccuracy: float = 0):#------------------------------------BLAST
	var pos = shoot_transform_spot.global_position
	var rot = shoot_rotate_spot.global_transform.basis
	var spwn = base_spell_effects(blast_scene, pos, rot)
	spwn.rotation_degrees.y += randf_range(-inaccuracy, inaccuracy)
	if spell_mods[Globals.spell_mod.EXTRA_AOE]:
		spwn.scale *= 2.0
	if spread_count > 0:
		spread_count -= 1
		cast_blast(60)

func base_spell_effects(scene: PackedScene, pos: Vector3, rot) -> Node3D:
	var spwn = scene.instantiate()
	add_sibling(spwn)
	var color = element_colors[imbuement]	
	spwn.set_color(color)
	spwn.type = imbuement
	spwn.global_position = pos
	spwn.transform.basis = rot
	if spell_mods[Globals.spell_mod.REFLECT]:
		spwn.add_to_group("Reflect")
	if spell_mods[Globals.spell_mod.EXTRA_DMG]:
		spwn.damage = spwn.damage + 50
	return spwn

func base_spell_costs() -> bool:
	if current_mana < spell_cost:
		if Globals.instant_spell_cast:
			fizzle_spell()
		return false
	current_mana -= spell_cost
	if !Globals.infinite_spell_charge:
		spell_cost = 0
		cast_ui.cost_bar.value = 0
	spell_charges -= 1
	return true
#endregion


func _process(delta: float) -> void:
	super(delta)
	cast_ui.mana_bar.value = current_mana

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
	#print("set_spell_mods", spell_mods)
	spell_charges = 1
	if spell_mods[Globals.spell_mod.EXTRA_CHARGE]:
		spell_charges = 3
	for i in range(Globals.spell_mod.size()):
		if i < 5 && _mods[i] == true:
			imbuement = i as Globals.element_type
			My_Globals.set_color(element_colors[i], book_displays[current_magic-1])

func set_spell_type(_type: Globals.spell_type):
	if current_magic != 0:
		book_displays[current_magic-1].visible = false
		My_Globals.set_color(element_colors[0], book_displays[current_magic-1])
	current_magic = _type
	book_displays[current_magic-1].visible = true
	#print(element_colors[type], current_magic, book_displays[current_magic].get_active_material(0).albedo_color)

func fizzle_spell():
	print("fizzle")
	book_displays[current_magic-1].visible = false
	My_Globals.set_color(element_colors[0], book_displays[current_magic-1])
	current_magic = Globals.spell_type.NONE
	imbuement = Globals.element_type.NONE
	spell_mods.fill(false)
	cast_ui.cost_bar.value = 0

func update_hp():
	cast_ui.health_bar.value = float(current_health)/float(max_health)

func kill():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	TransitionManager.scene_transition(0)
