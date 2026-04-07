extends Node3D

@export var npc_scene: PackedScene
@export var spawn_points: Array[Marker3D]
@export var entry_points: Array[Node3D]
@onready var spawn_timer = $Timer
func _ready():
	if GlScript.shop_open:
		_update_spawn_timer()

func _update_spawn_timer():
	if GlScript.shop_open:
		var current_npc_count = get_tree().get_nodes_in_group("nps").size()
		
		if current_npc_count < 4:
			spawn_npc()
		
		# Если репутация 1 > ждем 70 сек, если 10 -> ждем 20 сек
		var wait_time = remap(GlScript.reputation, 1, 10, randi_range(60,80), randi_range(10,30))
		wait_time = clamp(wait_time, 20, 70)
		
		spawn_timer.start(wait_time)
func spawn_npc():
	var new_npc = npc_scene.instantiate()
	var selected_marker = spawn_points.pick_random()
	
	new_npc.targets = entry_points
	new_npc.speed = 10
	

	get_tree().current_scene.add_child.call_deferred(new_npc)
	
	new_npc.set_deferred("global_position", selected_marker.global_position)
	
	new_npc.add_to_group("nps")

func _on_timer_timeout():
	_update_spawn_timer()
