## Basic class for displaying [InventoryItem]s. [br]
## Do not add these into the scene manualy. (see [member Inventory.items])
@tool @icon("res://addons/SwiftInv/Icons/InventorySlot.svg")
class_name InventorySlot extends TextureRect

## Emitted when [method update_slot] is called. [br]
## (only when [member item] changed by default)
signal slot_updated()

## Whether the [InventorySlot] updates itself every [method MainLoop._process] frame.
@export var auto_update: bool = true

@export_group("Drag Preview")
## If drag preview should change texture filter to nearest.
@export var drag_preview_pixel_art: bool = false


@export_group("Nodes")
## Displays [member InventoryItem.amount].
@export var amount_label: Label

## The nodes order in [InventoryContainer].
var index: int:
	set(value):
		pass
	get():
		return get_index()

@export_group("")
## Directly changes and displays [InventoryItem] in it's parents [Inventory]. [br]
## (PS: this variables SetGet sometimes throws this error, don't bother with it XD): [br]
## [color=bf3030]   editor/editor_data.cpp:1214 - Condition "!p_node->is_inside_tree()" is true.
@export var item: InventoryItem:
	set(value):
		if value:
			value = value.duplicate()
		if get_parent() is InventoryContainer:
			get_parent().inventory.items[index] = value
			update_slot()
	get():
		if not get_parent() is InventoryContainer: return null
		return get_parent().inventory.items[index]


## Write down expression in the form of a [String]. [br]
## If the expressions return true, you can drop currently dragged data into it.
@export_multiline var filters: String = ""


## This variables use is intended for use in [member filters] only. [br]
## Any other uses may not work correctly.
var dragged_item: InventoryItem


func _ready() -> void:
	update_slot()


## Updates [member texture_rect] and [member amount_label]. [br]
## Called with [method Node._process] by if [member auto_update] is [code]true[/code]. [br]
## If you want to change how the updating is handled, override this function.
func update_slot() -> void:
	if item:
		texture = item.texture
		if amount_label:
			if item.amount > 1:
				amount_label.text = str(item.amount)
			else:
				amount_label.text = ""
	else:
		texture = null
		if amount_label: amount_label.text = ""
	slot_updated.emit()


func are_filters_valid() -> bool:
	if not filters: return true
	var _expression: Expression = Expression.new()
	var error = _expression.parse(filters)
	if error == OK:
		return _expression.execute([], self)
	else:
		push_error("Invalid expression: %s." % filters)
		return false


func _get_drag_data(at_position: Vector2) -> Variant:
	if not item:
		return
	if get_parent() is not InventoryContainer:
		push_error("Slot parent is not InventoryContainer")
		return
	var data: Dictionary = {}
	data["base_inventory"] = get_parent().inventory
	data["base_slot"] = self
	data["base_item"] = get_parent().inventory.items[index]
	set_drag_preview(_get_preview(data["base_item"]))
	return data

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	dragged_item = data["base_item"]
	return are_filters_valid() and data is Dictionary

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data["base_slot"] == self: return
	if not item or not data["base_item"].name == item.name or item.amount == item.max_stack:
		data["base_slot"].item = item
		item = data["base_item"]
	else:
		var combined = data["base_item"].amount + item.amount
		var overflow = combined - item.max_stack 
		if overflow > 0:
			data["base_item"].amount = overflow
			item.amount = item.max_stack
		else:
			data["base_slot"].item = null
			item.amount = combined
	update_slot()
	data["base_slot"].update_slot()

func _get_preview(item: InventoryItem) -> Control:
	var preview_texture_rect: TextureRect = TextureRect.new()
	var preview_amount_label: Label = Label.new()
	
	preview_texture_rect.texture = texture
	preview_texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if drag_preview_pixel_art else CanvasItem.TEXTURE_FILTER_LINEAR
	preview_texture_rect.expand_mode = 1
	preview_texture_rect.size = Vector2(100,100)
	preview_texture_rect.position = -preview_texture_rect.size / 2
	
	preview_amount_label.add_theme_font_size_override("font_size", 100 / 2)
	preview_amount_label.text = str(item.amount) if item.amount > 1 else ""
	preview_amount_label.position = preview_texture_rect.size / 2 * Vector2(1, -1)
	
	var preview = Control.new()
	preview.add_child(preview_texture_rect)
	preview.add_child(preview_amount_label)
	
	return preview
