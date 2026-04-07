extends Control
@onready var first_item: Control = $HBoxContainer/first_item
@onready var two_item: Control = $HBoxContainer/two_item
@onready var thee_item: Control = $HBoxContainer/thee_item
@onready var four_item: Control = $HBoxContainer/four_item
@onready var fifth_item: Control = $HBoxContainer/fifth_item
@onready var sixth_item: Control = $HBoxContainer/sixth_item

@onready var take_item: Control = $HBoxContainer/take_item

@onready var first_item_sprite_2d: Sprite2D = $HBoxContainer/first_item/first_item_Sprite2D
@onready var two_item_sprite_2d: Sprite2D = $HBoxContainer/two_item/two_item_Sprite2D
@onready var thee_item_sprite_2d: Sprite2D = $HBoxContainer/thee_item/thee_item_Sprite2D
@onready var four_item_sprite_2d: Sprite2D = $HBoxContainer/four_item/four_item_Sprite2D
@onready var fifth_item_sprite_2d: Sprite2D = $HBoxContainer/fifth_item/fifth_item_Sprite2D
@onready var sixth_item_sprite_2d: Sprite2D = $HBoxContainer/sixth_item/sixth_item_Sprite2D
@onready var take_item_sprite_2d: Sprite2D = $HBoxContainer/take_item/take_item_Sprite2D
@onready var equals: Control = $HBoxContainer/Equals

@export var count_item: int
@export var first_item_res: Resource
@export var two_item_res: Resource
@export var tree_item_res: Resource
@export var four_item_res: Resource
@export var fifth_item_res: Resource
@export var sixth_item_res: Resource
@export var take_item_res: Resource

func _ready() -> void:
	equals.visible = false
	thee_item.visible = false
	four_item.visible = false
	fifth_item.visible = false
	sixth_item.visible = false
	
func _update_view():
	if first_item_res != null and two_item_res != null:
		equals.visible = true
		take_item.visible = true
		var pict_1 = first_item_res.book_pict_item
		var pict_2 = two_item_res.book_pict_item
		if tree_item_res != null:
			var pick_3 = tree_item_res.book_pict_item
			thee_item.visible = true
			thee_item_sprite_2d.texture = pick_3
		if four_item_res != null:
			var pick_4 = four_item_res.book_pict_item
			four_item.visible = true
			four_item_sprite_2d.texture = pick_4
		if fifth_item_res != null:
			var pick_5 = fifth_item_res.book_pict_item
			fifth_item.visible = true
			fifth_item_sprite_2d.texture = pick_5
		if sixth_item_res != null:
			var pick_6 = sixth_item_res.book_pict_item
			sixth_item.visible = true
			sixth_item_sprite_2d.texture = pick_6
		var pick_take = take_item_res.book_pict_item
		first_item_sprite_2d.texture = pict_1
		two_item_sprite_2d.texture = pict_2
		take_item_sprite_2d.texture = pick_take
	else:
		first_item_sprite_2d.texture = null
		two_item_sprite_2d.texture = null
		thee_item_sprite_2d.texture = null
		four_item_sprite_2d.texture = null
		thee_item.visible = false
		four_item.visible = false
		fifth_item.visible = false
		sixth_item.visible = false
		take_item.visible = false
		equals.visible = false
