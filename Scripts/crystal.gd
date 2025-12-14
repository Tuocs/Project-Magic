extends Control

signal crystal_charge_signal(value: int)
signal crystal_finish_spell()
var is_active = false
var mouse_sensitivity = 1
var selector_pos: Vector2 = Vector2(0,0)
@export var selector: Control
@export var selection_box: Control
@export var radius: float
@export var offset: Vector2
@export var main_crystal = false


@export var expanded_visuals: Control


func activate():
	is_active = true
	selector_pos = Vector2.ZERO
	expanded_visuals.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#mouse_filter = Control.MOUSE_FILTER_STOP
func deactivate():
	if !is_active:
		return
	var viewport_size = get_viewport().size
	var center_of_screen = viewport_size / 2
	Input.warp_mouse(center_of_screen)
	
	is_active = false
	expanded_visuals.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	selector_pos = Vector2.ZERO
	#mouse_filter = Control.MOUSE_FILTER_IGNORE
func charge(type: int):
	emit_signal("crystal_charge_signal", type)
	if main_crystal:
		emit_signal("crystal_charge_signal", type)
		emit_signal("crystal_finish_spell")
		get_parent().get_parent().deactivate()
	deactivate()

func _input(event: InputEvent) -> void:
	if !is_active: 
		return
	if event.is_action_released("magic_cast"):
		charge_selector_hover()
	if event is InputEventMouseMotion:
		selector_pos.y += event.relative.y * mouse_sensitivity
		selector_pos.x += event.relative.x * mouse_sensitivity
		
		selector_pos = selector_pos.limit_length(radius)
		selector.position = selector_pos + offset
		if (selector_pos.y < 0) && (abs(selector_pos.y) > abs(selector_pos.x)):
			selection_box.set_position(Vector2(100,0))
		if (selector_pos.y > 0) && (abs(selector_pos.y) > abs(selector_pos.x)):
			selection_box.set_position(Vector2(100,200))
		if (selector_pos.x > 0) && (abs(selector_pos.x) > abs(selector_pos.y)):
			selection_box.set_position(Vector2(200,100))
		if (selector_pos.x < 0) && (abs(selector_pos.x) > abs(selector_pos.y)):
			selection_box.set_position(Vector2(0,100))
			
func charge_selector_hover():
	if (selector_pos.y < 0) && (abs(selector_pos.y) > abs(selector_pos.x)):
		selection_box.set_position(Vector2(100,0))
		charge(Unit.element_type.BLUE)
	if (selector_pos.y > 0) && (abs(selector_pos.y) > abs(selector_pos.x)):
		selection_box.set_position(Vector2(100,200))
		charge(Unit.element_type.GREEN)
	if (selector_pos.x > 0) && (abs(selector_pos.x) > abs(selector_pos.y)):
		selection_box.set_position(Vector2(200,100))
		charge(Unit.element_type.RED)
	if (selector_pos.x < 0) && (abs(selector_pos.x) > abs(selector_pos.y)):
		selection_box.set_position(Vector2(0,100))
		charge(Unit.element_type.YELLOW)
