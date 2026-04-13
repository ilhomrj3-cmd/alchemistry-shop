extends Node


var craft_act = false
var inv_act = false
var craft_act_shader = false
var shop_open = true
var day = false
var change_price = true
var player_coin = 0
var reputation = 10
var player_shop: CharacterBody3D
var all_ingredients = {
	1: preload("res://Scena/Managers/Inv_managers/Items/ingredientes/Berry.tres"),
	2: preload("res://Scena/Managers/Inv_managers/Items/ingredientes/Goblin_ear.tres"),
	3: preload("res://Scena/Managers/Inv_managers/Items/ingredientes/god_slime.tres"),
	4: preload("res://Scena/Managers/Inv_managers/Items/ingredientes/Oculaberry.tres")
}

var all_potions = {
	101: preload("res://Scena/Managers/Inv_managers/Items/poison/Heath_potion(level_1).tres"),
	102: preload("res://Scena/Managers/Inv_managers/Items/poison/Manna_potion(1_level).tres"),
	103: preload("res://Scena/Managers/Inv_managers/Items/poison/Speed_potion(level_1).tres"),
	104: preload("res://Scena/Managers/Inv_managers/Items/poison/Phytotherapy_potion(level_1).tres"),
	105: preload("res://Scena/Managers/Inv_managers/Items/poison/Harmony_potion.tres")
}

# ФУНКЦИИ ДЛЯ РАБОТЫ С ЦЕНАМИ

func get_item_price(item_id: int):
	if all_potions.has(item_id):
		return all_potions[item_id].price
	else:
		print_debug("Ti obasralsy")

var active_shelves: Array[Node3D] = []

# очередь на кассу
var cashier_queue: Array[CharacterBody3D] = []

func register_shelf(shelf):
	if not active_shelves.has(shelf):
		active_shelves.append(shelf)
		print_debug("Стелла на базу: ", shelf.name)

func unregister_shelf(shelf):
	active_shelves.erase(shelf)
