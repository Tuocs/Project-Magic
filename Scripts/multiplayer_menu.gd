extends Control

func _on_join_button_pressed() -> void:
	MultiplayerManager.join_as_player($MarginContainer/Panel/MarginContainer/VBoxContainer/GridContainer/Panel/TextEdit.text)
	MenuManager.close_menu()

func _on_host_button_pressed() -> void:
	MultiplayerManager.become_host()
	MenuManager.close_menu()

func _on_join_local_button_2_pressed() -> void:
	MultiplayerManager.join_as_player()
	MenuManager.close_menu()
