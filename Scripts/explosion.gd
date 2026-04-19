extends Attack

func _on_area_entered(body):
	if body.is_in_group("Unit"):
		body.hit(damage, type)
		body.add_status_effect(type, 5)
		if knockback != 0:
			body.apply_knockback(owner_node.global_position, knockback)
		if knockup != 0:
			body.apply_knockback(body.global_position + Vector3(0,-10,0), knockup)
