extends Control



func _on_join_button_pressed() -> void:
	MultiplayerManager.join_as_player()
	MenuManager.close_menu()

func _on_host_button_pressed() -> void:
	MultiplayerManager.become_host()
	MenuManager.close_menu()
