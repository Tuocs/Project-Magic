extends Control

@export var edit_overlay: Control
@onready var player = get_parent()
var is_active = false
@export var crystals: Array[Control]
var stored_imbue_type: int = -1
var stored_spell_type: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func activate():
	is_active = true
	edit_overlay.visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
func deactivate():
	is_active = false
	edit_overlay.visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for element in crystals:
		element.deactivate()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	stored_imbue_type = -1
	stored_spell_type = -1

func _imbuement_crystal_charge(type: int):
	stored_imbue_type = type
	
func _spell_crystal_charge(type: int):
	stored_spell_type = type
	
func _finilize_spell():
	if stored_spell_type != -1:
		player.prepare_spell(stored_spell_type)
	if stored_imbue_type != -1:
		player.imbue(stored_imbue_type)
