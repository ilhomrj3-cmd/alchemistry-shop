extends Node3D

@export var npc_scene: PackedScene
@export var spawn_points: Array[Marker3D]
@export var entry_points: Array[Node3D]
@onready var spawn_timer = $Timer


func _ready():
	_update_spawn_timer()

func _update_spawn_timer():
	var current_npc_count = get_tree().get_nodes_in_group("nps").size()
	
	if current_npc_count < 4:
		print_debug("thith tsen has not 4 nps")
		spawn_npc()
	
	# Если репутация 1 > ждем 40 сек, если 10 -> ждем 20 сек
	var wait_time = remap(GlScript.reputation, 1, 10, randi_range(60,80), randi_range(25,40))
	wait_time = clamp(wait_time, 30, 60)
	
	spawn_timer.start(wait_time)

func spawn_npc():
	var new_npc = npc_scene.instantiate()
	var selected_marker = spawn_points.pick_random()
	var spawn_pos = selected_marker.global_position
	new_npc.scale = Vector3(8.0, 8.0, 8.0)
	new_npc.global_position = spawn_pos + Vector3(0, 2, 0)
	print("DEBUG: Спавню NPC в точке: ", spawn_pos) 
	
	new_npc.global_position = spawn_pos
	
	new_npc.targets = entry_points
	new_npc.speed = 10
	
	get_tree().current_scene.add_child(new_npc)
	new_npc.add_to_group("nps")

func _on_timer_timeout():
	_update_spawn_timer()
