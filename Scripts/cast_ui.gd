extends Control

@onready var edit_overlay = $"Edit Overlay"
@onready var mana_bar = $"Mana Bar/TextureProgressBar"
@onready var health_bar = $"HP Bar/TextureProgressBar"
@onready var spell_details = $"Edit Overlay/Spell Details"
@onready var selector = $"Edit Overlay/Center/small"
@onready var player = get_parent()
var is_active = false
var cursor_active = false
var instant_cast: bool

#spell stuff
@export var crystals: Array[Control]
var spell_type_data: Globals.spell_type = Globals.spell_type.NONE
var spell_mod_data: Array[bool] = []

#fake cursor stuff
var mouse_sensitivity = 0.5
var selector_pos: Vector2 = Vector2(0,0)
@export var radius: float
@export var offset: Vector2
@export var center_radius: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spell_mod_data.resize(Globals.spell_mod.size())
	spell_mod_data.fill(false)

func activate():
	is_active = true
	cursor_active = true
	selector.visible = true
	edit_overlay.visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
func deactivate():
	if !is_active:
		return
	_finilize_spell()
	is_active = false
	selector_pos = Vector2.ZERO
	selector.position = selector_pos + offset
	edit_overlay.visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	spell_details.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spell_details.visible = false
	for element in crystals:
		element.reset_charge_texture()
		element.deactivate()
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	spell_mod_data.fill(false)

func _imbuement_crystal_charge(_type: int):
	spell_mod_data[_type] = true
	_open_spell_details()
	
func _spell_crystal_charge(_type: int):
	spell_type_data = _type as Globals.spell_type
	_open_spell_details()

func _open_spell_details():
	spell_details.mouse_filter = Control.MOUSE_FILTER_STOP
	spell_details.visible = true
	cursor_active = true
	selector.visible = true

func _finilize_spell():
	if spell_type_data == Globals.spell_type.NONE:
		return;
	player.spell_cost = 0
	player.spell_cost += 1
	player.set_spell_type(spell_type_data)
	player.spell_cost += count_array_values(spell_mod_data,true)
	player.set_spell_mods(spell_mod_data)
	if instant_cast:
		Input.action_press("magic_cast")

func _input(event: InputEvent) -> void:
	if !is_active || !cursor_active: 
		return
	var sections = crystals.size()-1
	var section = get_section(sections)
	if event is InputEventMouseMotion:
		selector_pos.y += event.relative.y * mouse_sensitivity
		selector_pos.x += event.relative.x * mouse_sensitivity
		
		selector_pos = selector_pos.limit_length(radius)
		selector.position = selector_pos + offset
		match section:
			#highlight section here
			pass
	if event.is_action_pressed("magic_cast"):
		if (selector_pos.distance_to(Vector2.ZERO) < center_radius):
			crystals[0].activate()
		else:
			crystals[section+1].activate()
		cursor_active = false
		selector.visible = false


func get_section(section_count: int) -> int:
	if selector_pos == Vector2.ZERO:
		return -1
	var angle = atan2(selector_pos.y, selector_pos.x) # -PI .. PI
	angle = fposmod(angle, TAU) # 0 .. TAU
	var slice_size = TAU / section_count
	angle = fposmod(angle + slice_size * 0.5, TAU) # CENTER offset
	return int(angle / slice_size)

func count_array_values(_array, _target_value) -> int:
	var count = 0
	for item in _array:
		if item == _target_value:
			count += 1
	return count
