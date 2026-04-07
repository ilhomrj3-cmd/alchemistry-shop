extends Control

@export var first_item_res_chaild: Resource
@export var two_item_res_chaild: Resource
@export var tree_item_res_chaild: Resource
@export var four_item_res_chaild: Resource
@export var fifth_item_res_chaild: Resource
@export var sixth_item_res_chaild: Resource
@export var take_item_res_chaild: Resource

@onready var chaild: Control = $Recipes_ui_manager

func _process(_delta: float) -> void:
	chaild.first_item_res = first_item_res_chaild
	chaild.two_item_res = two_item_res_chaild
	chaild.tree_item_res = tree_item_res_chaild
	chaild.four_item_res = four_item_res_chaild
	chaild.fifth_item_res = fifth_item_res_chaild
	chaild.sixth_item_res = sixth_item_res_chaild
	chaild.take_item_res = take_item_res_chaild
	chaild._update_view()
