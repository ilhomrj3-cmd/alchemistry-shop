extends Node3D

@export var camera: Camera3D
var intered = true
func _process(_delta: float) -> void:

	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1.0
	
	var target_point = camera.project_ray_origin(mouse_pos) + camera.project_ray_normal(mouse_pos) * ray_length
	if intered:
		look_at(target_point, Vector3.UP)
	else:
		var pos = Vector3(10.4, 120.2, 200.4)
		look_at(pos, Vector3.UP)

func _on_button_5_mouse_entered() -> void:
	intered = false



func _on_button_5_mouse_exited() -> void:
	intered = true
