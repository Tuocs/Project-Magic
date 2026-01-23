extends Control

var Level1
@export var versionText: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	versionText.text = ProjectSettings.get_setting("application/config/version")
	Globals.infinite_spell_charge = false
	Globals.instant_spell_cast = false
	Globals.toggle_spell_window = false

func _on_button_2_pressed() -> void:
	TransitionManager.scene_transition(1)

func _on_infinite_charge_toggled(toggled_on: bool) -> void:
	Globals.infinite_spell_charge = toggled_on
func _on_instant_cast_toggled(toggled_on: bool) -> void:
	Globals.instant_spell_cast = toggled_on
func _on_toggle_ui_toggled(toggled_on: bool) -> void:
	Globals.toggle_spell_window = toggled_on
