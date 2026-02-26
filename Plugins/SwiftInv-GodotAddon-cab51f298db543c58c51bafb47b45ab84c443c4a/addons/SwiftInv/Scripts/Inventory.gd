## Basic [Inventory] resource.
@tool @icon("res://addons/SwiftInv/Icons/Inventory.svg")
class_name Inventory extends Resource


## Emited after most altering functions
signal inventory_changed(change_id: Changes)


## Types of changes for [signal inventory_changed] [br]
## Most are very self-explanatory.
enum Changes {
	## Used when inventory enters tree
	GENERAL_UPDATE,
	ITEM_ADDED,
	ITEM_REMOVED,
	ITEM_MOVED,
	SIZE_CHANGED,
}


## Manualy changing [member items] size automaticaly adds [InventorySlot]s to the scene tree.
@export var items: Array[InventoryItem] = []:
	set(value):
		if value.size() != items.size():
			items = value
			inventory_changed.emit(Changes.SIZE_CHANGED)
		else:
			items = value

## Stores an [InventoryItem] in the first empty slot. [br]
## Returs [constant FAILED] if item couldn't be added and [constant ok] otherwise.
func add_item(item: InventoryItem) -> Error:
	if is_full():
		return FAILED
	add_item_to(item, get_first_empty())
	return OK

## Stores an [InventoryItem] at the specified index. [br]
## Returs [constant FAILED] if item couldn't be added and [constant ok] otherwise.
func add_item_to(item: InventoryItem, index: int) -> Error:
	if not is_slot_empty(index):
		return FAILED
	items[index] = item
	inventory_changed.emit(Changes.ITEM_ADDED)
	return OK

## Returns an [InventoryItem] at the specified index. [br]
## Returs [code]null[/code] if item isn't found.
func get_item_by_index(index: int) -> InventoryItem:
	if not is_slot_empty(index):
		return items[index]
	else:
		push_error("No item with index %s found." % index)
		return null

## Moves an [InventoryItem] from a position to another. [br]
## Automaticaly swaps [InventoryItem]s if both from and to indexes have an [InventoryItem]. [br]
## Returs [constant FAILED] if items couldn't be moved and [constant ok] otherwise.
func move_from_to(from: int, to: int) -> Error:
	if is_slot_empty(from):
		return FAILED
	elif is_slot_empty(to):
		items[to] = items[from]
	else:
		var tmp: InventoryItem = items[to]
		items[to] = items[from]
		items[from] = tmp
	inventory_changed.emit(Changes.ITEM_MOVED)
	return OK


## Removes an [InventoryItem] from the inventory at the specified index. [br]
## Returs [constant FAILED] if item isn't found and [constant OK] otherwise.
func remove_by_index(index: int) -> Error:
	if is_slot_empty(index):
		push_error("No item found.")
		return FAILED
	else:
		items.remove_at(index)
		inventory_changed.emit(Changes.ITEM_REMOVED)
		return OK

## Returns [code]true[/code] if inventory is full.
func is_full() -> bool:
	if get_first_empty() == -1:
		return true
	else:
		return false

## Returns the first empty slot index. [br]
## If [code]from[/code] is invalid or inventory is full, returns [code]-1[/code]
func get_first_empty(from: int = 0) -> int:
	# start outside of range
	if from >= items.size():
		push_error("Invalid Inventory Index. Returning -1")
		return -1
	
	# check each slot
	for i in range(from, items.size()):
		if not items[i]: return i
	
	# no empty slots found
	push_warning("Inventory Full. Returning -1")
	return -1

## Returns [code]true[/code] if there is no [InventoryItem] at index.
func is_slot_empty(index: int) -> bool:
	if items[index]:
		return false
	else:
		return true

## Returns [code]true[/code] if has spcified [InventoryItem].
func has_item(item: InventoryItem) -> bool:
	return items.has(item)
