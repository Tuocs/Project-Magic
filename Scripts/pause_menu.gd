extends Control

@onready var charge: CheckButton = $"MarginContainer/Panel/MarginContainer/VBoxContainer/Panel3/Infinite Charge"
@onready var instant: CheckButton = $"MarginContainer/Panel/MarginContainer/VBoxContainer/Panel2/Instant Cast"
@onready var toggle: CheckButton = $"MarginContainer/Panel/MarginContainer/VBoxContainer/Panel/Toggle UI"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	charge.button_pressed = Globals.infinite_spell_charge
	instant.button_pressed = Globals.instant_spell_cast
	toggle.button_pressed = Globals.toggle_spell_window


func _on_infinite_charge_toggled(toggled_on: bool) -> void:
	Globals.infinite_spell_charge = toggled_on
func _on_instant_cast_toggled(toggled_on: bool) -> void:
	Globals.instant_spell_cast = toggled_on
func _on_toggle_ui_toggled(toggled_on: bool) -> void:
	Globals.toggle_spell_window = toggled_on


func _on_button_pressed() -> void:
	SceneManager.scene_transition(0)
