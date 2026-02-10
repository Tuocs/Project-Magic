extends Control

@export var fade_bar: ColorRect


var MenuScene
var Hub
var Forest
var City
var Room

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MenuScene = preload("res://Scenes/main_menu.tscn")
	Hub = preload("res://Scenes/hub.tscn")
	Room = preload("res://Scenes/room.tscn")
	Forest = preload("res://Scenes/forest.tscn")
	City = preload("res://Scenes/city.tscn")
	if fade_bar == null:
		create_new_fade_bar()
	reveal_scene()


func scene_transition(level_to_load: int):
	await hide_scene()
	await get_tree().create_timer(0.5).timeout
	match level_to_load:
		0:
			get_tree().change_scene_to_packed(MenuScene)
		1:
			get_tree().change_scene_to_packed(Hub)
			await get_tree().tree_changed
			var map_node = $"/root/Hub/Map"
			var newmap = Room.instantiate()
			map_node.add_child(newmap, true)
	if fade_bar == null:
		create_new_fade_bar()
	reveal_scene()

func map_transition(map_to_load: int):
	await hide_scene()
	await get_tree().create_timer(0.5).timeout
	var map_node = $"/root/Hub/Map"
	var entity_node = $"/root/Hub/Entities"
	var unit_node = $"/root/Hub/Units"
	if map_node:
		var children = map_node.get_children()#old map
		for child in children:
			child.queue_free()
		children = entity_node.get_children()#old entities
		for child in children:
			child.queue_free()
		children = unit_node.get_children()#old enemies
		for child in children:
			child.queue_free()
		var newmap
		match map_to_load:
			0:
				newmap = Room.instantiate()
			1:
				newmap = Forest.instantiate()
			2:
				newmap = City.instantiate()
		map_node.add_child(newmap, true)
	var player_array = get_tree().get_nodes_in_group("Player")
	for player in player_array:
		player.respawn.rpc()
		player.respawn()
	if fade_bar == null:
		create_new_fade_bar()
	reveal_scene()

func reveal_scene():
	var screen_size = get_viewport().size.x
	if fade_bar == null:
		create_new_fade_bar()
	for i in range(100):
		fade_bar.size.x = (100-i)*(screen_size/25)
		await get_tree().process_frame 
	InteractionManager.emit_signal("scene_loaded")
	if get_tree().current_scene.name == "Main Menu":
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_scene():
	var screen_size = get_viewport().size.x
	if fade_bar == null:
		create_new_fade_bar()
	for i in range(100):
		fade_bar.size.x = i*(screen_size/25)
		await get_tree().process_frame 
	MenuManager.close_menu()

func create_new_fade_bar():
	var fade_bar_canvas = CanvasLayer.new()
	fade_bar_canvas.layer = 4000
	add_child(fade_bar_canvas)
	fade_bar = ColorRect.new()
	fade_bar_canvas.add_child(fade_bar)
	fade_bar.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	fade_bar.color = Color(0.024, 0.039, 0.024, 1.0)
	fade_bar.size = Vector2(10000, 6000)
	fade_bar.position = Vector2(0, -2700)
	fade_bar.rotation_degrees = 33
	fade_bar.z_index = 4096

func _input(event: InputEvent) -> void:
	if event.is_action("Reload"):
		SceneManager.map_transition(0)
