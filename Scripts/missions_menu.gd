extends Control

func _on_button_pressed() -> void:
	SceneManager.map_transition(1)


func _on_button_2_pressed() -> void:
	SceneManager.map_transition(2)
