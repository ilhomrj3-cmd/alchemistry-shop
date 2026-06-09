extends Node3D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var label_3d: Label3D = $Press_E_lable/Label3D

@export var item_drop_res: Resource
@onready var player_item = preload("res://Scena/Managers/Inv_managers/INV/Player_INV.tres")

var is_player_inside: bool = false

func _ready() -> void:
	label_3d.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interaction") and is_player_inside:
		print_debug("PLayert_press_E")
		try_pick_up_item()


func try_pick_up_item() -> void:
	var item_added = false
	
	for i in range(player_item.items.size()):
		if player_item.items[i] == null:
			player_item.items[i] = item_drop_res
			item_added = true
			break 
			
	if item_added:
		queue_free()
	else:
		player.warning_panel._new_warning("output slot is full")

func _on_area_3d_take_item_body_entered(body: Node3D) -> void:
	print_debug(body)
	is_player_inside = true
	label_3d.visible = true

func _on_area_3d_take_item_body_exited(body: Node3D) -> void:
	is_player_inside = false
	label_3d.visible = false
