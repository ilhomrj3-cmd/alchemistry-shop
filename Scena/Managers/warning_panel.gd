extends Control
@onready var margin_container: MarginContainer = $MarginContainer
@onready var label: Label = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/Label
@onready var anim: AnimationPlayer = $MarginContainer/Animation_warning_panel
var couldawn = true
var all_news = {
	"incorrect_ingredient_order": "Wrong ingredient order or ingredient count! Check the recipe book.",
	"incorrect_ricipe": "Recipe not found. Check your recipe book.",
	"сannot change price": "Cannot change price while a customer is shopping.",
	"prices are too high": "Prices are too high! Customer are leaving.",
	"output slot is full": "Free up the slot to get your new item.",
	
}
func _ready() -> void:
	margin_container.visible = false
func _new_warning(name_warning: String):
	label.text = str(all_news[name_warning])
	if couldawn:
		anim.play("start")
		couldawn = false
		await anim.animation_finished
		couldawn = true
