extends Control

var Level1
var Level2
var Level3
@export var versionText: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Level1 = preload("res://Scenes/quick_cast_main.tscn")
	Level2 = preload("res://Scenes/manual_cast_main.tscn")
	Level3 = preload("res://Scenes/instant_manual_cast_main.tscn")
	versionText.text = ProjectSettings.get_setting("application/config/version")
	Globals.infinite_spell_charge = false
	Globals.instant_spell_cast = false
	Globals.toggle_spell_window = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(Level1)

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_packed(Level2)

func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_packed(Level3)


func _on_infinite_charge_toggled(toggled_on: bool) -> void:
	Globals.infinite_spell_charge = toggled_on


func _on_instant_cast_toggled(toggled_on: bool) -> void:
	Globals.instant_spell_cast = toggled_on


func _on_toggle_ui_toggled(toggled_on: bool) -> void:
	Globals.toggle_spell_window = toggled_on
