extends Control

enum MENU {NONE, ANY, PAUSE, MISSIONS, MULTIPLAYER, SPELL_BENCH}
@onready var pause_menu = $"Pause Menu"
@onready var missions_menu = $"Missions Menu"
@onready var multiplayer_menu = $"Multiplayer Menu"
var current_menu: MENU = MENU.NONE

func open_menu(type: MENU):
	if get_tree().current_scene.name == "Main Menu":
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if type == MENU.PAUSE:
		pause_menu.show()
		#get_tree().paused = true
		current_menu = MENU.PAUSE
	if type == MENU.MISSIONS:
		missions_menu.show()
		current_menu = MENU.MISSIONS
	if type == MENU.MULTIPLAYER:
		multiplayer_menu.show()
		current_menu = MENU.MULTIPLAYER
	
func close_menu():
	if current_menu == MENU.PAUSE:
		pause_menu.hide()
		#get_tree().paused = false
	if current_menu == MENU.MISSIONS:
		missions_menu.hide()
	if current_menu == MENU.MULTIPLAYER:
		multiplayer_menu.hide()
	current_menu = MENU.NONE
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	if event.is_action_released("escape"):
		if current_menu == MENU.NONE:
			open_menu(MENU.PAUSE)
		else:
			close_menu()
