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
var recipes = [
	[
		{"id": 1, "count": 2},
		{"id": 2, "count": 1}
	],
	[
		{"id": 3, "count": 2},
		{"id": 2, "count": 2}
	],
	[
		{"id": 2, "count": 2},
		{"id": 3, "count": 1},
	]
]

var cooked_recipes = [
	"Health",
	"Manna",
	"SPEED"
]
var all_potion = {
	"Health": preload("res://Scena/Managers/Inv_managers/Items/poison/Heath_potion(level_1).tres"),
	"Manna": preload("res://Scena/Managers/Inv_managers/Items/poison/Manna_potion(1_level).tres"),
	"SPEED": preload("res://Scena/Managers/Inv_managers/Items/poison/Speed_potion(level_1).tres")
	
}

var ingredientes = []
var count_ingredientes = []

func _process(delta: float) -> void:

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
	var current_ingredients = []
	for i in inventory_container.items:
		if i != null:
			current_ingredients.append({"id": i.Id, "count": i.amount})
	
	var found_recipe_index = -1
	
	for r_index in range(recipes.size()):
		var recipe = recipes[r_index]
		if recipe.size() == current_ingredients.size():
			var matches = 0
			for i in range(recipe.size()):
				if recipe[i]["id"] == current_ingredients[i]["id"] and current_ingredients[i]["count"] >= recipe[i]["count"]:
					matches += 1
			
			if matches == recipe.size():
				found_recipe_index = r_index
				break

	if found_recipe_index != -1:
		var target_recipe = recipes[found_recipe_index]
		
		var recipe_step = 0
		for i in range(inventory_container.items.size()):
			var item = inventory_container.items[i]
			if item != null:

				item.amount -= target_recipe[recipe_step]["count"]
				
				if item.amount <= 0:
					inventory_container.items[i] = null
				
				recipe_step += 1
				
		print_debug("Зелье сварено: ", cooked_recipes[found_recipe_index])
		finish_cook.play()
		var potion_name = cooked_recipes[found_recipe_index]
		var new_potion_res = all_potion[potion_name]


		if craft_item_take.items[0] == null:
			var potion_instance = new_potion_res.duplicate()
			potion_instance.amount = 2
			craft_item_take.items[0] = potion_instance
		else:
			if craft_item_take.items[0].Id == new_potion_res.Id:
				craft_item_take.items[0].amount += 2
			else:
				print_debug("Слот выдачи занят другим предметом!")
				return 

		for slot in node_inventory_container.get_children():
			if slot.has_method("update_slot"):
				slot.update_slot()
		slot_0.update_slot()
	else:
		print_debug("Не удалось сварить. Проверь ингредиенты!")

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
					break
			
			if not success:
				print_debug("У игрока нет места для возврата предмета: ", item_in_cauldron.name)
		for slot in node_inventory_container.get_children():
			if slot.has_method("update_slot"):
				slot.update_slot()
		slot_0.update_slot()
	item_foget = false
