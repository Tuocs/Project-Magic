extends Control

@onready var edit_overlay = $"Edit Overlay"
@onready var mana_bar = $"Mana Bar/TextureProgressBar"
@onready var cost_bar = $"Mana Bar/TextureProgressBar2"
@onready var health_bar = $"HP Bar/TextureProgressBar"
@onready var spell_details = $"Edit Overlay/Spell Details"
@onready var selector = $"Edit Overlay/MainCursor"
@onready var highlight = $"Edit Overlay/Highlight"
@onready var player = get_parent()
@onready var player_input = $"../PlayerInput"
var is_active = false
var cursor_active = false
var sections: int = 0
var curent_section: int= -1

@export_category("Spell Settings")
@export var crystals: Array[Control]
var spell_type_data: Globals.spell_type = Globals.spell_type.NONE
var spell_mod_data: Array[bool] = []
@export var crystal_spawn_radius: float

@export_category("Mouse Settings")
var mouse_sensitivity = 0.5
var selector_pos: Vector2 = Vector2(0,0)
@export var cursor_radius: float
@export var cursor_offset: Vector2
@export var center_zone_radius: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spell_mod_data.resize(Globals.spell_mod.size())
	spell_mod_data.fill(false)
	sections = crystals.size()-1
	cursor_offset = (size/2) - Vector2(100,100)
	move_crystals_in_circle()
	cost_bar.value = 0

func activate():
	is_active = true
	cursor_active = true
	selector.visible = true
	edit_overlay.visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	highlight.position = cursor_offset# + Vector2(72,72)
	cost_bar.value = 0
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func deactivate():
	if !is_active:
		return
	_finilize_spell()
	is_active = false
	selector_pos = Vector2.ZERO
	selector.position = selector_pos + cursor_offset
	edit_overlay.visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	spell_details.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spell_details.visible = false
	for element in crystals:
		element.reset_charge_texture()
		element.deactivate()
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	spell_mod_data.fill(false)

func _crystal_charge():
	spell_details.mouse_filter = Control.MOUSE_FILTER_STOP
	spell_details.visible = true
	cursor_active = true
	selector.visible = true
	for i in range(crystals.size()):
		if i == 0 && crystals[i].charged_option != null:
			cost_bar.value = 1
		elif crystals[i].charged_option != null:
			cost_bar.value += 1

func _finilize_spell():
	for i in range(crystals.size()):
		if i == 0 && crystals[i].charged_option != null:
			spell_type_data = crystals[i].charged_option
			crystals[i].charged_option = null
			cost_bar.value = 1
		elif crystals[i].charged_option != null:
			spell_mod_data[crystals[i].charged_option] = true
			crystals[i].charged_option = null
			cost_bar.value += 1
	if spell_type_data == Globals.spell_type.NONE:
		return;
	var spell_cost = 1
	spell_cost += Globals.count_array_values(spell_mod_data,true)
	cost_bar.value = spell_cost
	player_input.prepare_spell(spell_type_data, spell_mod_data)
	if Globals.instant_spell_cast:
		Input.action_press("magic_cast")

func _input(event: InputEvent) -> void:
	if !is_active || !cursor_active: 
		return
	if event is InputEventMouseMotion:
		selector_pos.y += event.relative.y * mouse_sensitivity
		selector_pos.x += event.relative.x * mouse_sensitivity
		selector_pos = selector_pos.limit_length(cursor_radius)
		selector.position = selector_pos + cursor_offset
		get_section(sections)
		
		highlight.position = crystals[curent_section].position + Vector2(72,72)
		#if (selector_pos.distance_to(Vector2.ZERO) < center_zone_radius): this detected if the mouse was in the middle but it didnt feel great
		#if spell_details.visible == false:
		#	highlight.position = cursor_offset + Vector2(72,72)
	
	if event.is_action_pressed("magic_cast"):
		get_section(sections)
		#if (selector_pos.distance_to(Vector2.ZERO) < center_zone_radius): this detected if the mouse was in the middle but it didnt feel great
		crystals[curent_section].activate()
		cursor_active = false
		selector.visible = false

func get_section(section_count: int) -> int:
	var angle = atan2(selector_pos.y, selector_pos.x) # -PI .. PI
	angle = fposmod(angle, TAU) # 0 .. TAU
	var slice_size = TAU / section_count
	angle = fposmod(angle + slice_size * 0.5, TAU) # CENTER offset
	var new_section = int(angle / slice_size)
	#add one for center section
	if spell_details.visible == false:
		new_section = 0
	elif selector_pos == Vector2.ZERO:
		return -1
	else:
		new_section+=1
	#animation logic
	if new_section != curent_section:
		crystals[curent_section].off_crystal_hovered()
		curent_section = new_section
		crystals[curent_section].on_crystal_hovered()
	return new_section

func move_crystals_in_circle():
	var angle_increment = TAU / sections # TAU is 2 * PI radians (360 degrees)
	for i in range(sections):
		var current_angle = (angle_increment * i)# + deg_to_rad(54)
		var x = cos(current_angle) * crystal_spawn_radius
		var y = sin(current_angle) * crystal_spawn_radius
		var spawn_position = cursor_offset + Vector2(x, y) + Vector2(75,75)
		crystals[i+1].position = spawn_position
		crystals[i+1].find_children("*", "AnimationComponent")[0].enter_position = -Vector2(x, y)

func _process(delta: float) -> void:
	health_bar.value = float(player.current_health)/float(player.max_health)
