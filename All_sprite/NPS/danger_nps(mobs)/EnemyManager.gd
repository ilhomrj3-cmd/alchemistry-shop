
extends Node

const MAX_ATTACKERS: int = 1
var _active_attackers: Array = []

func request_attack_token(enemy) -> bool:
	_active_attackers = _active_attackers.filter(func(e): return is_instance_valid(e))
	if _active_attackers.size() < MAX_ATTACKERS and enemy not in _active_attackers:
		_active_attackers.append(enemy)
		return true
	return false

func release_attack_token(enemy) -> void:
	_active_attackers.erase(enemy)

func get_all_enemies() -> Array:
	return get_tree().get_nodes_in_group("enemy")

# Возвращает желаемый угол позиции для окружения игрока.
# Каждый моб получает свой "слот" на окружности.
func get_flank_angle(enemy) -> float:
	var enemies = get_all_enemies().filter(func(e): return is_instance_valid(e) and not e.is_dead)
	var idx = enemies.find(enemy)
	if idx < 0 or enemies.size() == 0:
		return 0.0
	return (TAU / enemies.size()) * idx
