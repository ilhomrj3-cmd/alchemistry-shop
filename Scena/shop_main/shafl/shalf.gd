extends Node3D
@onready var potion_SFX = $potion_down
var player_inv_check_poison = preload("res://Scena/Managers/Inv_managers/INV/Player_INV.tres")
var shelf_inventory = preload("res://Scena/Managers/Inv_managers/INV/Shalf_inv.tres")
@onready var spawn_points = [$position_mark/pos,$position_mark/pos2,$position_mark/pos3,$position_mark/pos4,
$position_mark/pos5,$position_mark/pos7,$position_mark/pos8,$position_mark/pos9,
$position_mark/pos10,$position_mark/pos11,$position_mark/pos12,$position_mark/pos13,$position_mark/pos14,
$position_mark/pos15,$position_mark/pos16, $position_mark/pos17, $position_mark/pos18,
 $position_mark/pos19, $position_mark/pos20, $position_mark/pos21, $position_mark/pos22, 
$position_mark/pos23, $position_mark/pos24, $position_mark/pos25, $position_mark/pos26, 
$position_mark/pos27, $position_mark/pos28, $position_mark/pos29, $position_mark/pos30, 
$position_mark/pos31, $position_mark/pos32, $position_mark/pos33, $position_mark/pos34, 
$position_mark/pos35, $position_mark/pos36, $position_mark/pos37, $position_mark/pos38, 
$position_mark/pos39, $position_mark/pos40, $position_mark/pos41, $position_mark/pos42, 
$position_mark/pos43, $position_mark/pos44, $position_mark/pos45, $position_mark/pos46, 
$position_mark/pos47, $position_mark/pos48, $position_mark/pos49, $position_mark/pos50, 
$position_mark/pos51, $position_mark/pos52, $position_mark/pos53, $position_mark/pos54, 
$position_mark/pos55, $position_mark/pos56, $position_mark/pos57, $position_mark/pos58, 
$position_mark/pos59, $position_mark/pos60]
var items = shelf_inventory.items
var items_player = player_inv_check_poison.items



func transfer_potions_to_shelf():

	for i in range(items_player.size()):
		var item = items_player[i]
		if item != null and item.Id >= 30 and item.amount > 0:
			for j in range(items.size()):
				if items[j] == null:
					potion_SFX.play()
					var item_dubl = item.duplicate()
					item_dubl.amount = 1
					items[j] = item_dubl
					item.amount -= 1
					if item.amount <= 0:
						items_player[i] = null
					#print_debug(items)
					break
			break
	update_shelf_visuals()

func update_shelf_visuals():
	for marker in spawn_points:
		for child in marker.get_children():
			child.queue_free()

	for j in range(items.size()):
		var item_data = items[j]
		if item_data != null and j < spawn_points.size():
			var marker = spawn_points[j]
			if item_data.mesh_item:
				var mesh_to_spawn = item_data.mesh_item.instantiate()
				marker.add_child(mesh_to_spawn)
				
