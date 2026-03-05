extends StaticBody3D
@onready var mesh_instance_3d: MeshInstance3D = $"../MeshInstance3D"

func interaction():
	GlScript.craft_act = true

func _process(delta: float) -> void:
	if GlScript.craft_act_shader:
		mesh_instance_3d.visible = true
	else:
		mesh_instance_3d.visible = false
