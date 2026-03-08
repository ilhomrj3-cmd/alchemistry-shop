
extends RayCast3D
@onready var can_up_ray_cast_3d: RayCast3D = $"../can_up_RayCast3D"

func _process(delta: float) -> void:
	if is_colliding():
		can_up_ray_cast_3d.enabled = false
	else:
		can_up_ray_cast_3d.enabled = true
