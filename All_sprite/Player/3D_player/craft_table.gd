extends MarginContainer

@onready var inventory_container = preload("res://Scena/Managers/Inv_managers/INV/Cauldron.tres")
@onready var node_inventory_container: InventoryContainer = $craft_visible/InventoryContainer
@onready var craft_item_take = preload("res://Scena/Managers/Inv_managers/INV/Craft_item_take.tres")
@onready var player_item = preload("res://Scena/Managers/Inv_managers/INV/Player_INV.tres")
@onready var node_craft_item_take: InventoryContainer = $craft_visible/Craft_item_take
@onready var slot_0: InventorySlot = $craft_visible/Craft_item_take/Slot0
@onready var fair_shader: Panel = $craft_panel_visible/fair_shader
@onready var cook_potion_sfx: AudioStreamPlayer2D = $cook_potion_SFX
@onready var finish_cook: AudioStreamPlayer2D = $finish_cook

var item_foget = false
var cauldron_visible = false
var indx = 0

var recipes_db = {
	101: [{"id": 1, "count": 2}, {"id": 2, "count": 1}], # Health Potion
	102: [{"id": 3, "count": 2}, {"id": 2, "count": 2}], # Mana Potion
	103: [{"id": 2, "count": 2}, {"id": 3, "count": 1}], # Speed Potion
	104: [{"id": 1, "count": 2}, {"id": 2, "count": 2}, {"id": 3, "count": 2}], # Phytotherapy
	105: [{"id": 1, "count": 1}, {"id": 2, "count": 1}, {"id": 3, "count": 1}, {"id": 4, "count": 1}] # Harmony
}


var ingredientes = []
var count_ingredientes = []
func _ready() -> void:
	item_foget = true
	foget_item_take_player()
	_update_ui_slots()
func _process(_delta: float) -> void:

	var has_items = false
	for item_check in inventory_container.items:
		if item_check != null:
			has_items = true
			break
	
	fair_shader.visible = has_items
	GlScript.craft_act_shader = has_items
	if has_items and not cook_potion_sfx.playing:
		cook_potion_sfx.play()
	elif not has_items:
		cook_potion_sfx.stop()
	if GlScript.craft_act == false:
		item_foget = true
		foget_item_take_player()
		
func _on_creat_button_pressed() -> void:
	_update_ui_slots()
	var current_ingredients = []
	for i in inventory_container.items:
		if i != null:
			current_ingredients.append({"id": i.Id, "count": i.amount})

	
	if current_ingredients.is_empty(): return

	var found_potion_id = -1
	
	for potion_id in recipes_db.keys():
		var recipe = recipes_db[potion_id]
		
		if recipe.size() != current_ingredients.size():
			continue
			
		var is_match = true
		for i in range(recipe.size()):
			if current_ingredients[i]["id"] != recipe[i]["id"] or current_ingredients[i]["count"] < recipe[i]["count"]:
				is_match = false
				break
		
		if is_match:
			found_potion_id = potion_id
			break
	if found_potion_id != -1:

		var target_recipe = recipes_db[found_potion_id]
		var ingredient_index = 0
		for i in range(inventory_container.items.size()):
			if inventory_container.items[i] != null:
				inventory_container.items[i].amount -= target_recipe[ingredient_index]["count"]
				if inventory_container.items[i].amount <= 0:
					inventory_container.items[i] = null
				ingredient_index += 1

		finish_cook.play()
		_update_ui_slots()
		var new_potion_res = GlScript.all_potions[found_potion_id]

		if craft_item_take.items[0] == null:
			var potion_instance = new_potion_res.duplicate()
			potion_instance.amount = 2
			craft_item_take.items[0] = potion_instance
			_update_ui_slots()
		else:
			if craft_item_take.items[0].Id == new_potion_res.Id:
				craft_item_take.items[0].amount += 2

				_update_ui_slots()
			else:
				print_debug("Слот выдачи занят!")
				return 

func _update_ui_slots():
	for slot in node_inventory_container.get_children():
		if slot.has_method("update_slot"):
			slot.update_slot()
	for craft_slot in node_craft_item_take.get_children():
		if craft_slot.has_method("update_slot"):
			craft_slot.update_slot()

func foget_item_take_player():
	if not item_foget: return

	for i in range(inventory_container.items.size()):
		var item_in_cauldron = inventory_container.items[i]
		
		if item_in_cauldron != null:
			var success = false
			

			for p in range(player_item.items.size()):
				if player_item.items[p] == null:

					player_item.items[p] = item_in_cauldron
					

					inventory_container.items[i] = null
					print_debug("Предмет вернулся игроку в слот: ", p)
					success = true
					item_foget = false
					_update_ui_slots()
					break
			
			if not success:
				_update_ui_slots()
				item_foget = false
				print_debug("У игрока нет места для возврата предмета: ", item_in_cauldron.name)
