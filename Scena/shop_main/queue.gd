extends StaticBody3D

@export var queue_markers: Array[Marker3D]
@export var item_display_markers: Array[Marker3D]
@export var cashier_inventory = preload("res://Scena/Managers/Inv_managers/INV/Cashier_inventory.tres")

var current_customers: Array[CharacterBody3D] = []

func _ready():
	add_to_group("cashier")
	if cashier_inventory:
		cashier_inventory = cashier_inventory.duplicate()
		for i in range(cashier_inventory.items.size()):
			cashier_inventory.items[i] = null

# Торги с NPC
func join_queue(npc) -> Vector3:
	if not current_customers.has(npc):
		current_customers.append(npc)
	
	var index = current_customers.find(npc)
	if index < queue_markers.size():
		return queue_markers[index].global_position
	return queue_markers.back().global_position

func interaction():
	if current_customers.is_empty(): 
		return
	
	# если первый NPC в очереди
	if not _is_display_empty():
		collect_money()

func _is_display_empty() -> bool:
	for item in cashier_inventory.items:
		if item != null: return false
	return true

func process_payment(npc):
	# Выворачиваем карманы NPC в кассу
	var npc_inv = npc.nps_inventory.items
	for i in range(npc_inv.size()):
		if npc_inv[i] != null:
			for j in range(cashier_inventory.items.size()):
				if cashier_inventory.items[j] == null:
					cashier_inventory.items[j] = npc_inv[i]
					npc_inv[i] = null
					break
	update_cashier_visuals()

func collect_money():
	var money_earned = 0
	for i in range(cashier_inventory.items.size()):
		if cashier_inventory.items[i] != null:
			money_earned += cashier_inventory.items[i].count
			cashier_inventory.items[i] = null
	
	GlScript.player_coin += money_earned
	print_debug("Получено денег: ", money_earned)
	
	update_cashier_visuals()
	
	# отпускаем покупателя
	var npc = current_customers.pop_front()
	if npc:
		npc.current_state = npc.State.LEAVING
		for customer in current_customers:
			customer.current_state = customer.State.GO_TO_CASHIER

func update_cashier_visuals():
	for marker in item_display_markers:
		for child in marker.get_children():
			child.queue_free()

	for i in range(cashier_inventory.items.size()):
		var item_data = cashier_inventory.items[i]
		if item_data and i < item_display_markers.size():
			var mesh = item_data.mesh_item.instantiate()
			item_display_markers[i].add_child(mesh)
