extends Area3D
class_name InteractionArea

@export var action_name: String = "Interact"

var interact: Callable = func():
	pass

func _on_body_exited(body: Node3D) -> void:
	if !body.is_in_group("Player"):
		return
	InteractionManager.unregister_area(self)
	print("remove interaction")


func _on_body_entered(body: Node3D) -> void:
	if !body.is_in_group("Player"):
		return
	InteractionManager.register_area(self)
	print("add interaction")
