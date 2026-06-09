extends CharacterBody3D

@export var target: Node3D 
@export var speed = 3.0  
@export var follow_distance = 4
@export var combat_range: float = 10.0 # Радиус обнаружения мобов
@export var damage: int = 250

var target_offset = Vector3.ZERO  
var change_timer = 0.0 
var is_locked_by_anim: bool = false
@onready var liriya_anim: AnimationTree = $Liriya/liriya_anim
@onready var nav_agent: NavigationAgent3D = $Navigation_liriya 
@onready var player = get_tree().get_first_node_in_group("player")
var look_target_pos = Vector3.ZERO
var look_timer = 20.0
var idle_angle = 50.0
var base_scale = Vector3(1, 1, 1)
var position_update_timer: float = 0.0
var has_bolt: bool = true
var nearby_mobs: Array[Node3D] = []
var target_index: int = 0
var current_target_mob: Node3D = null

func _ready():
	base_scale = global_transform.basis.get_scale()
	idle_angle = rotation.y
	has_bolt = true
func _physics_process(delta):
	if not target:
		return

	var current_pos = global_position
	var dist_to_player = current_pos.distance_to(target.global_position)
	var next_path_pos = nav_agent.get_next_path_position()

	if dist_to_player > 20.0:
		nav_agent.target_position = target.global_position
		speed = 5.0
	else:
		speed = 3.0

		var is_player_moving = target.velocity.length() > 0.1
		
		if is_player_moving:
			position_update_timer -= delta
			if position_update_timer <= 0:
				var player_back_dir = target.global_transform.basis.z.normalized()
				
				var side_offset = Vector3.ZERO
				if current_target_mob and is_instance_valid(current_target_mob):
					var dir_to_mob = target.global_position.direction_to(current_target_mob.global_position)
					var side_dir = Vector3(-dir_to_mob.z, 0, dir_to_mob.x).normalized()
					side_offset = side_dir * 1.0 # 1.5 метра вбок
					
				target_offset = (player_back_dir * follow_distance) + side_offset
				nav_agent.target_position = target.global_position + target_offset
				
				# тиймер
				position_update_timer = 0.7
		else:
			nav_agent.target_position = target.global_position + target_offset

	var target_rotation_y = 0.0
	if is_locked_by_anim:
		target_rotation_y = rotation.y
	elif Input.is_action_pressed("attack_command") and current_target_mob and is_instance_valid(current_target_mob):
		var dir_to_mob = (current_target_mob.global_position - current_pos).normalized()
		target_rotation_y = atan2(dir_to_mob.x, dir_to_mob.z)
	elif velocity.length() > 0.2:

		var walk_dir = (next_path_pos - current_pos).normalized()
		target_rotation_y = atan2(walk_dir.x, walk_dir.z)
	else:
		look_timer -= delta
		if look_timer <= 0:
			idle_angle = rotation.y + randf_range(deg_to_rad(-70), deg_to_rad(70))
			look_timer = randf_range(3.0, 4.0)
		target_rotation_y = idle_angle

	rotation.y = lerp_angle(rotation.y, target_rotation_y, delta * 3.0)
	global_transform.basis = global_transform.basis.scaled(base_scale / global_transform.basis.get_scale())

	var direction = (next_path_pos - current_pos).normalized()
	if is_locked_by_anim:
		velocity = Vector3.ZERO
	else:
		if dist_to_player > nav_agent.target_desired_distance + 0.2:
			velocity = direction * speed
		else:
			velocity = velocity.move_toward(Vector3.ZERO, speed * 0.1)

	if not is_locked_by_anim:
		_handle_animations()
	move_and_slide()

	_update_nearby_mobs()
	_handle_combat_input()

func _handle_animations() -> void:
	if velocity.length() > 0.1:
		if target.shield_equipped:
			liriya_anim["parameters/playback"].travel("walk_crossbow")
		else:
			liriya_anim["parameters/playback"].travel("walk")
	else:
		if target.shield_equipped:
			liriya_anim["parameters/playback"].travel("idle_crossbow_with")
		else:
			liriya_anim["parameters/playback"].travel("idle")

func _update_nearby_mobs() -> void:
	var all_mobs = get_tree().get_nodes_in_group("enemy")
	var valid_mobs: Array[Node3D] = []
	
	for enemy in all_mobs:
		if is_instance_valid(enemy) and global_position.distance_to(enemy.global_position) <= combat_range and not enemy.is_dead:
			valid_mobs.append(enemy)
			enemy.can_take_token = true
			
	if valid_mobs.size() != nearby_mobs.size():
		_clear_all_highlights()
		nearby_mobs = valid_mobs
		if nearby_mobs.is_empty():
			current_target_mob = null
			target_index = 0
		else:
			target_index = target_index % nearby_mobs.size()
			current_target_mob = nearby_mobs[target_index]
	
	if current_target_mob and is_instance_valid(current_target_mob):
		if "is_stanned" in current_target_mob and current_target_mob.is_stanned:
			_set_mob_highlight(current_target_mob, "red")
		else:
			_set_mob_highlight(current_target_mob, "yellow")

func _mod_attack_coldawn_set(enemys: Array):
	if enemys.size() == 1:
		for enemy in enemys:
			if not enemy.attack_cooldown_chaige:
				enemy.attack_cooldown = enemy.attack_cooldown / 4.0
				enemy.attack_cooldown_chaige = true
	elif enemys.size() == 2:
		for enemy in enemys:
			if not enemy.attack_cooldown_chaige:
				enemy.attack_cooldown = enemy.attack_cooldown / 2.5
				enemy.attack_cooldown_chaige = true
	elif enemys.size() == 3:
		for enemy in enemys:
			if not enemy.attack_cooldown_chaige:
				enemy.attack_cooldown = enemy.attack_cooldown / 5.0
				enemy.attack_cooldown_chaige = true
	else:
		for enemy in enemys:
			enemy.attack_cooldown = enemy.base_attack_cooldown
	
func _handle_combat_input() -> void:
	if nearby_mobs.is_empty():
		return
		
	if Input.is_action_just_pressed("torget_lock"):
		_clear_all_highlights()
		target_index = (target_index + 1) % nearby_mobs.size()
		current_target_mob = nearby_mobs[target_index]
		
	if Input.is_action_pressed("attack_command") and not player.dont_move_okey:
		if liriya_anim:
			liriya_anim["parameters/playback"].travel("shot") 

func _set_mob_highlight(enemy: Node3D, color_type: String) -> void:
	if enemy.has_method("set_target_glow"):
		enemy.set_target_glow(color_type)

func _clear_all_highlights() -> void:
	for enemy in nearby_mobs:
		if is_instance_valid(enemy) and enemy.has_method("set_target_glow"):
			enemy.set_target_glow("none")

func _order_shoot() -> void:
	if current_target_mob and is_instance_valid(current_target_mob) and not player.dont_move_okey:
		if "is_stanned" in current_target_mob and current_target_mob.is_stanned and has_bolt: 
			if current_target_mob.has_method("take_damage"):
				current_target_mob.take_damage(damage)
			if current_target_mob.has_method("_you_got_shot"):
				current_target_mob._you_got_shot(global_position)
			_clear_all_highlights()
func lock_movement() -> void:
	is_locked_by_anim = true
	velocity = Vector3.ZERO

func unlock_movement() -> void:
	is_locked_by_anim = false
func spend_bolt() -> void:
	has_bolt = false
func load_bolt() -> void:
	has_bolt = true
