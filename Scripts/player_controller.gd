extends Unit

@export_category("Player Options")
@export var mouse_sensitivity: float = 0.001
@onready var cam = $SpringArm3D/Node3D/Camera3D
var cast_ui
@onready var projectile_scene = preload("res://Prefabs/Spawnables/projectile.tscn")
@onready var blast_scene = preload("res://Prefabs/Spawnables/blast.tscn")
@onready var aura_scene = preload("res://Prefabs/Spawnables/aura.tscn")
@onready var structure_scene = preload("res://Prefabs/Spawnables/structure.tscn")
@export var shoot_transform_spot: Node3D
@export var shoot_rotate_spot: Node3D
@export var book_displays: Array[Node3D]
var spread_count: int = 0
var unlimited_cast: bool
@onready var player_input = $PlayerInput

@export_category("Player Sync Exports")
@export var do_jump = false
@export var do_cast = false
@export var spell_cost: int = 1
@export var spell_charges: int = 0
@export var current_magic: Globals.spell_type = Globals.spell_type.NONE
@export var spell_mods: Array[bool] = []
@export var imbuement: Globals.element_type = Globals.element_type.NONE
#var _is_on_floor = true

func _ready():
	super()
	cast_ui = $"Cast UI"
	cast_ui.health_bar.value = current_health
	spell_mods.resize(Globals.spell_mod.size())
	spell_mods.fill(false)


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
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().get_direct_space_state()
	var query := PhysicsRayQueryParameters3D.create(player_input.look_vector_origin, player_input.look_vector_target)
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
	spwn.owner_node = self
	$"/root/Hub/Entities".add_child(spwn)
	var color = element_colors[imbuement]
	spwn.set_color(color)
	spwn.type = imbuement
	spwn.global_position = pos
	spwn.transform.basis = rot
	if spell_mods[Globals.spell_mod.REFLECT]:
		spwn.add_to_group("Reflect")
	if spell_mods[Globals.spell_mod.EXTRA_DMG]:
		spwn.damage = spwn.damage + 50
	if spell_mods[Globals.spell_mod.DURATION_UP]:
		spwn.lifetime = spwn.lifetime*2
	if spell_mods[Globals.spell_mod.DURATION_DOWN]:
		spwn.lifetime = spwn.lifetime/3
	if spell_mods[Globals.spell_mod.PUSH]:
		spwn.knockback = 8
	if spell_mods[Globals.spell_mod.PULL]:
		spwn.knockback = -8
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

func update_spellbook_visuals():
	for i in range(book_displays.size()):
		book_displays[i].visible = false
		My_Globals.set_color(element_colors[0], book_displays[i])
	if current_magic-1 >= 0:
		book_displays[current_magic-1].visible = true
		My_Globals.set_color(element_colors[imbuement], book_displays[current_magic-1])



func _process(delta: float) -> void:
	if is_dead:
		return
	super(delta)
	cast_ui.mana_bar.value = current_mana
	if do_cast && !cast_ui.is_active:
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
		do_cast = false
		if multiplayer.is_server():
			rpc_update_spellbook.rpc()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_apply_movement(delta)

func _apply_movement(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if do_jump and is_on_floor():
		velocity.y = JUMP_VELOCITY
		do_jump = false
	var direction := (transform.basis * Vector3(player_input.input_dir.x, 0, player_input.input_dir.y)).normalized()
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
	update_spellbook_visuals()
	if multiplayer.is_server():
		rpc_update_spellbook.rpc()

func set_spell_type(_type: Globals.spell_type):
	current_magic = _type
	update_spellbook_visuals()
	if multiplayer.is_server():
		rpc_update_spellbook.rpc()
	#print(element_colors[type], current_magic, book_displays[current_magic].get_active_material(0).albedo_color)

func fizzle_spell():
	print("fizzle")
	current_magic = Globals.spell_type.NONE
	imbuement = Globals.element_type.NONE
	spell_mods.fill(false)
	cast_ui.cost_bar.value = 0
	update_spellbook_visuals()

func update_hp():
	pass



func kill():
	if is_dead:
		return
	is_dead = true
	disable.rpc()
	if Globals.get_alive_players().size() == 0:
		SceneManager.map_transition(0)
		return
	await get_tree().create_timer(10.0).timeout
	respawn.rpc()

@rpc("call_local")
func disable():
	hide()
	$CollisionShape3D.disabled = true

@rpc("call_local")
func respawn():
	if is_dead:
		show()
		$CollisionShape3D.disabled = false
		is_dead = false
	fizzle_spell()
	do_cast = false
	do_jump = false
	current_health = max_health
	current_mana = max_mana
	position = Vector3.ZERO
	rotation = Vector3.ZERO
	is_dead = false



@rpc("call_local")
func rpc_update_spellbook():
	update_spellbook_visuals()
