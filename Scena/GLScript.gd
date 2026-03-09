extends Node

var craft_act = false
var inv_act = false
var craft_act_shader = false
var shop_open = false
var day = false
var player_coin = 0
var reputation = 1


var active_shelves: Array[Node3D] = []

# очередь на кассу
var cashier_queue: Array[CharacterBody3D] = []

func register_shelf(shelf):
	if not active_shelves.has(shelf):
		active_shelves.append(shelf)
		print_debug("Стелла на базу: ", shelf.name)

func unregister_shelf(shelf):
	active_shelves.erase(shelf)
