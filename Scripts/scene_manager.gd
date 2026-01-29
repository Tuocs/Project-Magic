extends Control

@export var fade_bar: ColorRect

var MenuScene
var Level1
var Hub

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MenuScene = preload("res://Scenes/main_menu.tscn")
	Level1 = preload("res://Scenes/main.tscn")
	Hub = preload("res://Scenes/home.tscn")
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
			get_tree().change_scene_to_packed(Level1)
		2:
			get_tree().change_scene_to_packed(Hub)
		_:
			get_tree().change_scene_to_packed(MenuScene)
	if fade_bar == null:
		create_new_fade_bar()
	reveal_scene()

func reload_scene():
	await hide_scene()
	get_tree().reload_current_scene()
	await get_tree().create_timer(0.2).timeout
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
	if event.is_action_pressed("Reload"):
		reload_scene()
