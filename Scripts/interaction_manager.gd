extends Node

signal scene_loaded()
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var label = $"CanvasLayer/Interact Highlight"

var active_areas = []
var can_interact = true

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	label = $"CanvasLayer/Interact Highlight"
	
func scene_loaded_ready():
	player = get_tree().get_first_node_in_group("Player")

func register_area(area: InteractionArea):
	active_areas.push_back(area)

func unregister_area(area: InteractionArea):
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)

func _process(delta: float) -> void:
	if player == null:
		return
	if active_areas.size() > 0:
		active_areas.sort_custom(_sort_by_distance_to_player)
		label.show()
	else:
		label.hide()

func _sort_by_distance_to_player(area1,area2):
	var a1 = player.global_position.distance_to(area1.global_position)
	var a2 = player.global_position.distance_to(area2.global_position)
	return a1 < a2

func _input(event):
	if event.is_action_pressed("interact") && can_interact:
		if active_areas.size() > 0:
			can_interact = false
			await active_areas[0].interact.call()
			can_interact = true
