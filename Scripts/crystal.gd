extends Control

#@export_category("General Settings")
var is_active = false
var texture_rects: Array[TextureRect]
var sections: int = 0
@export var cast_ui: Control
@onready var expanded_visuals = $"largeBG"

@export_category("Mouse Settings")
@export var mouse_sensitivity = 1
var cursor_pos: Vector2 = Vector2(0,0)
@onready var cursor_visuals = $"largeBG/Edit Overlay/smallCursor"
@export var cursor_radius: float
@export var cursor_offset: Vector2

@export_category("Spell Settings")
@onready var selection_box = $"largeBG/Edit Overlay/selector"
@export var spawn_radius: float = 100.0
@export var spell_mods: Array[Globals.spell_mod]
@export var charge_textures: Array[Texture]

@export_category("Main Crystal Settings")
@export var is_main_crystal: bool = false
@export var spell_types: Array[Globals.spell_type]


func _ready() -> void:
	sections = charge_textures.size()-1
	spawn_rects_in_circle()

func activate():
	#print("opened crystal")
	is_active = true
	cursor_pos = Vector2.ZERO
	expanded_visuals.visible = true
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#mouse_filter = Control.MOUSE_FILTER_STOP

func deactivate():
	if !is_active:
		return
	var viewport_size = get_viewport().size
	var center_of_screen = viewport_size / 2
	Input.warp_mouse(center_of_screen)
	is_active = false
	expanded_visuals.visible = false
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	cursor_pos = Vector2.ZERO
	#mouse_filter = Control.MOUSE_FILTER_IGNORE

func charge(_section: int):
	if is_main_crystal:
		cast_ui._type_crystal_charge(spell_types[_section])
	else:
		cast_ui._mod_crystal_charge(spell_mods[_section])
	$Button.texture_normal = charge_textures[_section+1]
	deactivate()

func reset_charge_texture():
	$Button.texture_normal = charge_textures[0]

func _input(event: InputEvent) -> void:
	if !is_active: 
		return
	var section = get_section(sections)
	if event is InputEventMouseMotion:
		cursor_pos.y += event.relative.y * mouse_sensitivity
		cursor_pos.x += event.relative.x * mouse_sensitivity
		
		cursor_pos = cursor_pos.limit_length(cursor_radius)
		cursor_visuals.position = cursor_pos + cursor_offset
		selection_box.position = texture_rects[section].position
	if event.is_action_released("magic_cast"):
		charge(section)

func get_section(section_count: int) -> int:
	if cursor_pos == Vector2.ZERO:
		return -1
	var angle = atan2(cursor_pos.y, cursor_pos.x) # -PI .. PI
	angle = fposmod(angle, TAU) # 0 .. TAU
	var slice_size = TAU / section_count
	angle = fposmod(angle + slice_size * 0.5, TAU) # CENTER offset
	return int(angle / slice_size)

func spawn_rects_in_circle():
	var angle_increment = TAU / sections # TAU is 2 * PI radians (360 degrees)
	for i in range(sections):
		var current_angle = angle_increment * i
		var x = cos(current_angle) * spawn_radius
		var y = sin(current_angle) * spawn_radius
		var spawn_position = cursor_offset + Vector2(x, y)
		var new_rect = TextureRect.new()
		new_rect.texture = charge_textures[i+1]
		#new_rect.position = spawn_position
		new_rect.custom_minimum_size = Vector2(100, 100)
		new_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		$"largeBG/Edit Overlay".add_child(new_rect)
		$"largeBG/Edit Overlay".move_child(new_rect, 0)
		new_rect.position = spawn_position
		texture_rects.append(new_rect)
