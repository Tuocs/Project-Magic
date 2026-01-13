extends Area3D


func _on_area_entered(body):
	print("killbox hit ",body)
	if body.is_in_group("Unit"):
		body.kill()
