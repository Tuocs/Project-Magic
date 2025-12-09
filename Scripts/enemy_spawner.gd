extends Node3D

@export var enemy_scene: PackedScene
@export var target_enemy_count: int
@onready var my_timer = $Timer # Assuming your Timer node is named "Timer"

func _ready():
	my_timer.wait_time = randi_range(8,20)
	my_timer.start()

func _on_timer_timeout() -> void:
	print("timer")
	my_timer.wait_time = randi_range(4,10)
	var collectibles_in_scene: Array[Node] = get_tree().get_nodes_in_group("Enemy")
	var count: int = collectibles_in_scene.size()
	if count < target_enemy_count:
		spawn_enemy()

func spawn_enemy():
	var spwn = enemy_scene.instantiate()
	add_child(spwn)
	spwn.global_position = global_position
	spwn.transform.basis = global_transform.basis
