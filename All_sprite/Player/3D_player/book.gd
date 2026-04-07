extends MarginContainer
@onready var animation_book: AnimationPlayer = $Animation_book

@onready var colum_1: Control = $HBoxContainer/MarginContainer/VBoxContainer/Colum_1
@onready var colum_2: Control = $HBoxContainer/MarginContainer/VBoxContainer/Colum_2
@onready var colum_3: Control = $HBoxContainer/MarginContainer/VBoxContainer/Colum_3
@onready var colum_4: Control = $HBoxContainer/MarginContainer/VBoxContainer/Colum_4
@onready var colum_5: Control = $HBoxContainer/MarginContainer2/VBoxContainer/Colum_5
@onready var colum_6: Control = $HBoxContainer/MarginContainer2/VBoxContainer/Colum_6
@onready var colum_7: Control = $HBoxContainer/MarginContainer2/VBoxContainer/Colum_7
@onready var colum_8: Control = $HBoxContainer/MarginContainer2/VBoxContainer/Colum_8
@onready var page_label: Label = $HBoxContainer/MarginContainer2/MarginContainer/page_Label

@export var page: int
var dont_next = false
func _ready() -> void:
	update_pages()

func update_pages():
	page_label.text = str(page)
	_page_one_now()
	_page_two_now()

func _on_button_forward_pressed() -> void:
	page += 1
	animation_book.play("next_list")
	await animation_book.animation_finished
	update_pages()

func _on_button_down_pressed() -> void:
	if page >= 2:
		page -= 1
		animation_book.play_backwards("next_list")
		await animation_book.animation_finished
		update_pages()

func _page_one_now():
	if page == 1:

		colum_1.first_item_res_chaild = GlScript.all_ingredients[1]
		colum_1.two_item_res_chaild = GlScript.all_ingredients[2]
		colum_1.take_item_res_chaild = GlScript.all_potions[101]

		colum_2.first_item_res_chaild = GlScript.all_ingredients[2]
		colum_2.two_item_res_chaild = GlScript.all_ingredients[3]
		colum_2.take_item_res_chaild = GlScript.all_potions[102]

		colum_3.first_item_res_chaild = GlScript.all_ingredients[3]
		colum_3.two_item_res_chaild = GlScript.all_ingredients[2]
		colum_3.take_item_res_chaild = GlScript.all_potions[103]

		colum_4.first_item_res_chaild = GlScript.all_ingredients[1]
		colum_4.two_item_res_chaild = GlScript.all_ingredients[2]
		colum_4.tree_item_res_chaild = GlScript.all_ingredients[3]
		colum_4.take_item_res_chaild = GlScript.all_potions[104]
	else:
		_clear_column(colum_1)
		_clear_column(colum_2)
		_clear_column(colum_3)
		_clear_column(colum_4)
		
func _page_two_now():
	if page == 1:
		colum_5.first_item_res_chaild = GlScript.all_ingredients[1]
		colum_5.two_item_res_chaild = GlScript.all_ingredients[2]
		colum_5.tree_item_res_chaild = GlScript.all_ingredients[3]
		colum_5.four_item_res_chaild = GlScript.all_ingredients[4]
		colum_5.take_item_res_chaild = GlScript.all_potions[105]
		_clear_column(colum_6)
		_clear_column(colum_7)
		_clear_column(colum_8)
	else:
		_clear_column(colum_5)
		_clear_column(colum_6)
		_clear_column(colum_7)
		_clear_column(colum_8)

func _clear_column(column):
	column.first_item_res_chaild = null
	column.two_item_res_chaild = null
	column.tree_item_res_chaild = null
	column.four_item_res_chaild = null
	if "take_item_res_chaild" in column:
		column.take_item_res_chaild = null
