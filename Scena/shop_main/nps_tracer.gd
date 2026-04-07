extends Area3D


var npcs_inside: Array[CharacterBody3D] = []

func _on_body_entered(body: Node3D) -> void:
	print("Объект вошел. Его группы: ", body.get_groups())
	if body is CharacterBody3D and body.is_in_group("nps"):
			if not npcs_inside.has(body):
				npcs_inside.append(body as CharacterBody3D)
			_update_price_lock()
			print("В магазине NPC! Всего: ", npcs_inside.size())

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D and body.is_in_group("nps"):
		if npcs_inside.has(body):
			npcs_inside.erase(body as CharacterBody3D)
		_update_price_lock()
		print("NPC вышел. Осталось: ", npcs_inside.size())

func _update_price_lock():
	GlScript.change_price = npcs_inside.is_empty()
