extends InventoryInfo


func on_info_changed() -> void:
	$PanelContainer/MarginContainer/VBoxContainer/Name.text = hovered_item.name
	$PanelContainer/MarginContainer/VBoxContainer/Desc.text = hovered_item.description
