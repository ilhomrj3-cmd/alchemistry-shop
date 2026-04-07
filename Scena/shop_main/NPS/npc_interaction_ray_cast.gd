extends RayCast3D

func _process(_delta: float) -> void:
	if is_colliding():
		var hitobj = get_collider()
		if hitobj.has_method("use_nps"):
			hitobj.use_nps()
