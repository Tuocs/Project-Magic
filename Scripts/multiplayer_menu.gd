extends Control

func _on_join_button_pressed() -> void:
	await MultiplayerManager.join_as_player($MarginContainer/Panel/MarginContainer/VBoxContainer/GridContainer/Panel/TextEdit.text)
	MenuManager.close_menu()
	var map_node = $"/root/Hub/Map"
	var children = map_node.get_children()#old map
	for child in children:
		child.queue_free()

func _on_host_button_pressed() -> void:
	await MultiplayerManager.become_host()
	MenuManager.close_menu()
	SceneManager.map_transition(0)

func _on_join_local_button_2_pressed() -> void:
	await MultiplayerManager.join_as_player()
	MenuManager.close_menu()
	var map_node = $"/root/Hub/Map"
	var children = map_node.get_children()#old map
	for child in children:
		child.queue_free()
