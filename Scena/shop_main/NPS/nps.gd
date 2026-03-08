extends CharacterBody3D

@export var targets: Array[Node3D]
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@export var speed: int
var target_idx = 0
var up = false
func _ready():
	_update_target()

func _physics_process(_delta):
	# Если мы уже на последнем маркере и навигация закончена — ничего не делаем
	if target_idx >= targets.size():
		velocity.x = 0
		velocity.z = 0
		# Не забываем про гравитацию, чтобы он не завис в воздухе
		if not is_on_floor():
			velocity.y -= 80 * _delta
		move_and_slide()
		return

	if nav_agent.is_navigation_finished():
		# Просто прибавляем индекс
		target_idx += 1
		
		# Проверяем: есть ли еще маркеры?
		if target_idx < targets.size():
			_update_target()
		else:
			print_debug("Путь окончен. NPC пришел в финальную точку.")
			return # Выходим, чтобы не выполнять код движения ниже

	var next_path_pos = nav_agent.get_next_path_position()

	var current_pos_2d = global_position
	var next_pos_2d = next_path_pos

	current_pos_2d.y = 0
	next_pos_2d.y = 0

	var direction = current_pos_2d.direction_to(next_pos_2d)

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	if not is_on_floor():
		velocity.y -= 80 * _delta
	if velocity.length() > 0.1:
		var look_target = global_position + Vector3(velocity.x, 0, velocity.z)
		look_at(look_target, Vector3.UP)
	if $CollisionShape3D/can_up_RayCast3D.is_colliding() and is_on_floor():
		print_debug("I collid")

		velocity.y = 20

	move_and_slide()

func _update_target():
	if targets.size() > 0:
		nav_agent.target_position = targets[target_idx].global_position
