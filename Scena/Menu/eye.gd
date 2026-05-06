extends Node3D

@export var camera: Camera3D
@export var smooth_speed: float = 5.0


var intered = true
var current_target: Vector3 = Vector3.ZERO

func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1.0
	
	var desired_target: Vector3
	
	if intered:
		desired_target = camera.project_ray_origin(mouse_pos) + camera.project_ray_normal(mouse_pos) * ray_length
	else:
		desired_target = Vector3(10.4, 120.2, 200.4)


	current_target = current_target.lerp(desired_target, smooth_speed * delta)
	
	look_at(current_target, Vector3.UP)

func _on_quit_button_mouse_entered() -> void:
	intered = false

func _on_quit_button_mouse_exited() -> void:
	intered = true
