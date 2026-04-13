extends Control

@onready var player_shop: CharacterBody3D = $"../../../../../../.."
@export var item_show: Resource
@onready var line_edit: LineEdit = $HBoxContainer/Control4_entry_prine/VBoxContainer/MarginContainer/LineEdit
@onready var texture_item: TextureRect = $HBoxContainer/Control_sprite_item/MarginContainer/TextureRect
@onready var market_price_label: Label = $HBoxContainer/Control2_market_price/MarginContainer/market_price_Label
@onready var player_price_label: Label = $HBoxContainer/Control3_your_price/MarginContainer/your_price_Label
@onready var name_item_label: Label = $MarginContainer/name_item_Label
var player_price = 0

func _ready() -> void:
	texture_item.texture = item_show.book_pict_item
	market_price_label.text = str(item_show.market_price)
	name_item_label.text = item_show.name
	player_price_label.text = str(item_show.player_price)

func _on_line_edit_text_submitted(new_text: String) -> void:
	player_price = int(new_text)
	if GlScript.change_price:
		var new_price_modifier = player_price
		if new_price_modifier < 0 or len(str(new_price_modifier)) > 5:
			pass
		else:
			player_price_label.text = str(new_price_modifier)
			item_show.price = new_price_modifier
		line_edit.clear()
	else:
		player_shop.warning_panel._new_warning("сannot change price")
		print_debug("Не взя менять цены пока покупатели выбирают товары")
	
	
