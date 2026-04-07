extends Node3D

@onready var skeleton_3d: Skeleton3D = $Armature/Skeleton3D

func get_only_meshes():
	var meshes = []
	for child in skeleton_3d.get_children():
		if child is MeshInstance3D:
			meshes.append(child)
	return meshes

func _ready() -> void:
	var children = skeleton_3d.get_children()
	var mesh_count = skeleton_3d.get_child_count()
	
	for i in range(mesh_count):
		var child = children[i]
		if child is MeshInstance3D:
			child.visible = false
	
	if mesh_count > 0:
		var random_index = randi() % mesh_count
		var random_npc = children[random_index]
		
		if random_npc is MeshInstance3D:
			random_npc.visible = true
			print("Появился персонаж: ", random_npc.name)
		else:
			children[0].visible = true
