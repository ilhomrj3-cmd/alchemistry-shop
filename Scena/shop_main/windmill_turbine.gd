extends MeshInstance3D
func _process(delta: float) -> void:
	rotate_z(0.1 * delta)
