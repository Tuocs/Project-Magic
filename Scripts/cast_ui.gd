extends Control

@onready var edit_overlay = $"Edit Overlay"
@onready var mana_bar = $"Mana Bar/TextureProgressBar"
@onready var spell_details = $"Edit Overlay/Spell Details"
@onready var selector = $"Edit Overlay/Center/small"
@onready var player = get_parent()
var is_active = false
var cursor_active = false
@export var crystals: Array[Control]
var stored_imbue_type: int = -1
var stored_spell_type: int = -1
@export var auto_crystal: Control
var instant_cast: bool
var mouse_sensitivity = 1
var selector_pos: Vector2 = Vector2(0,0)
@export var radius: float
@export var offset: Vector2
@export var center_radius: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func activate():
	is_active = true
	cursor_active = true
	selector.visible = true
	edit_overlay.visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if auto_crystal != null:
		auto_crystal.activate()
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
	if auto_crystal != null:
		auto_crystal.charge_selector_hover()
	for element in crystals:
		element.reset_charge_texture()
		element.deactivate()
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	stored_imbue_type = -1
	stored_spell_type = -1

func _imbuement_crystal_charge(type: int):
	stored_imbue_type = type
	_open_spell_details()
	
func _spell_crystal_charge(type: int):
	stored_spell_type = type
	_open_spell_details()

func _open_spell_details():
	spell_details.mouse_filter = Control.MOUSE_FILTER_STOP
	spell_details.visible = true
	cursor_active = true
	selector.visible = true

func _finilize_spell():
	player.spell_cost = 0
	if stored_spell_type != -1:
		player.spell_cost += 1
		player.prepare_spell(stored_spell_type)
	if stored_imbue_type != -1:
		player.spell_cost += 1
		player.imbue(stored_imbue_type)
	else:
		player.imbue(0)
	if instant_cast:
		Input.action_press("magic_cast")
		

func _input(event: InputEvent) -> void:
	if !is_active || !cursor_active: 
		return
	var sections = crystals.size()-1
	var section = get_section(selector_pos, sections)
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


func get_section(selector_pos: Vector2, section_count: int) -> int:
	if selector_pos == Vector2.ZERO:
		return -1

	var angle = atan2(selector_pos.y, selector_pos.x) # -PI .. PI
	angle = fposmod(angle, TAU) # 0 .. TAU

	var slice_size = TAU / section_count
	angle = fposmod(angle + slice_size * 0.5, TAU) # CENTER offset

	return int(angle / slice_size)
