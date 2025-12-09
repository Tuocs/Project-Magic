extends Control

var Level1
var Level2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Level1 = preload("res://Scenes/quick_cast_main.tscn")
	Level2 = preload("res://Scenes/manual_cast_main.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(Level1)


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_packed(Level2)
