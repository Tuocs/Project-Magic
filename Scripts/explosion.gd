extends Attack

func _on_area_entered(body):
	if body.is_in_group("Unit"):
		body.hit(damage, type)
