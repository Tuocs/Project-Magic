extends Control

signal crystal_charge_signal(value: int)
var is_active = false
var mouse_sensitivity = 1
var selector_pos: Vector2 = Vector2(0,0)
@export var selector: Control
@export var selection_box: Control
@export var cursor_radius: float
@export var cursor_offset: Vector2
@export var charge_textures: Array[Texture]
@export var expanded_visuals: Control
@export var spawn_radius: float = 100.0 # Radius of the circle
var sections: int = 0

func _ready() -> void:
	sections = charge_textures.size()-1
	spawn_rects_in_circle()

func activate():
	is_active = true
	selector_pos = Vector2.ZERO
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
	selector_pos = Vector2.ZERO
	#mouse_filter = Control.MOUSE_FILTER_IGNORE
func charge(type: int):
	emit_signal("crystal_charge_signal", type)
	$Button.texture_normal = charge_textures[type]
	deactivate()
	
func reset_charge_texture():
	$Button.texture_normal = charge_textures[0]

func _input(event: InputEvent) -> void:
	if !is_active: 
		return
	var section = get_section(sections)
	if event is InputEventMouseMotion:
		selector_pos.y += event.relative.y * mouse_sensitivity
		selector_pos.x += event.relative.x * mouse_sensitivity
		
		selector_pos = selector_pos.limit_length(cursor_radius)
		selector.position = selector_pos + cursor_offset
		match section:
			0:
				selection_box.position = Vector2(200, 100)
			1:
				selection_box.position = Vector2(100, 200)
			2:
				selection_box.position = Vector2(0, 100)
			3:
				selection_box.position = Vector2(100, 0)
	if event.is_action_released("magic_cast"):
		charge(section+1)


func get_section(section_count: int) -> int:
	if selector_pos == Vector2.ZERO:
		return -1

	var angle = atan2(selector_pos.y, selector_pos.x) # -PI .. PI
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
		$"large/Edit Overlay".add_child(new_rect)
		$"large/Edit Overlay".move_child(new_rect, 0)
		new_rect.position = spawn_position
