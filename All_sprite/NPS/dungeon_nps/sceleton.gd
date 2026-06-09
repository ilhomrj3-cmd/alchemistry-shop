extends CharacterBody3D

@export var const_speed: float = 2.0
@export var attack_range: float = 4.0
@export var run_attack_range: float = 10.0
var base_attack_cooldown: float = 10.0
var attack_cooldown_chaige = false
@export var attack_cooldown: float = 10.0 
var attack_cooldown_timer: float = 0.0
@export var detection_range: float = 20.0
@export var search_radius: float = 10.0
@export var search_duration: float = 15.0
@export var look_around_time: float = 5.5
@export var rotation_speed: float = 6.0
@export var gravity: float = 9.8
@export var bash: float = 0
@export var mod_bash_cap: float = 10.0
@export var damage: int = 20
@export var Hp: int = 100
@export var push_force: float = 15.0
@export var fly_friction: float = 10.0

@export var circle_radius: float = 6.0       # радиус кружения вокруг игрока
@export var regroup_distance: float = 5.0    # на сколько отбежать после парирования
@export var regroup_duration: float = 2.5    # сколько секунд "собираться с мыслями"
@export var circle_speed_mult: float = 0.8   # скорость при кружении (множитель от const_speed)

@onready var damage_ui_plaece: Node3D = $damage_ui_plaece
@onready var targer_color: OmniLight3D = $body/mesh_anim/rig/Skeleton3D/BoneAttachment3D/markers/target_light
@onready var nav_agent = $Navigation_nps
@onready var player = get_tree().get_first_node_in_group("player")
@onready var mesh_nps = $body/mesh_anim
@onready var back_raycast: ShapeCast3D = $nps_colision/backraycast

var hurt_timer: float = 1.0
var custom_stan_duration: float = 2.0
var inctanse_damage_lable = preload("res://Scena/Managers/3d_manager/3d_ui_take_damage.tscn")
var can_take_token = false

enum State {
	IDLE, SEARCH_WALK, SEARCH_LOOK, CHASE,
	CIRCLE,
	RUN_ATTACK, ATTACK,
	REGROUP,  
	STUNNED, RETURN_HOME, HURT, FLY_BACK, DEAD
}

var current_state: State = State.IDLE
var speed = const_speed
var is_stanned = false
var can_bash = true
var search_timer: float = 0.0
var look_timer: float = 0.0
var spawn_position: Vector3
var spawn_rotation: Vector3
var is_locked_by_anim: bool = false
var fly_direction: Vector3 = Vector3.ZERO
var fly_speed: float = 0.0
var fly_timer: float = 0.0
var is_dead: bool = false

var has_attack_token: bool = false
var regroup_timer: float = 0.0
var _circle_angle: float = 0.0     
var _circle_dir: float = -1.0       

func _ready() -> void:
	nav_agent.target_desired_distance = 1.0
	randomize()
	await get_tree().process_frame
	spawn_position = global_position
	spawn_rotation = global_rotation
	is_dead = false

	_circle_dir = 1.0 if randi() % 2 == 0 else -1.0

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta
	if not player:
		move_and_slide()
		return
	if is_dead:
		return
	if current_state == State.FLY_BACK or current_state == State.DEAD:
		_execute_state(delta)
		move_and_slide()
		return

	if bash >= mod_bash_cap and not is_stanned:
		_apply_stan()
		return

	if is_stanned:
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return

	var target_position = player.global_position
	var distance_to_player = global_position.distance_to(target_position)

	_determine_state(distance_to_player, delta)
	_execute_state(delta)

	if is_locked_by_anim == false:
		damage_ui_plaece.look_at(target_position)
	else:
		velocity = Vector3.ZERO

	move_and_slide()

func _determine_state(distance: float, delta: float) -> void:
	if current_state == State.FLY_BACK or current_state == State.DEAD or is_dead:
		return
	if is_stanned:
		current_state = State.STUNNED
		return
	if current_state == State.HURT or current_state == State.REGROUP:
		return

	if distance <= attack_range:
		if has_attack_token:
			_set_state(State.ATTACK)
		elif current_state != State.REGROUP:
			_set_state(State.CIRCLE)

	elif distance <= run_attack_range:
		if has_attack_token:
			_set_state(State.RUN_ATTACK)
		elif current_state != State.REGROUP:
			_set_state(State.CIRCLE)

	elif distance <= detection_range:
		search_timer = 0.0
		_try_request_token() 
		_set_state(State.CHASE)

		if not has_attack_token:
			has_attack_token = EnemyManager.request_attack_token(self)
		_set_state(State.CHASE)

	elif current_state in [State.CHASE, State.RUN_ATTACK, State.ATTACK, State.CIRCLE]:
		_set_state(State.SEARCH_WALK)
		search_timer = search_duration
		_set_random_search_target()

	elif current_state in [State.SEARCH_WALK, State.SEARCH_LOOK]:
		search_timer -= delta
		if search_timer <= 0:
			nav_agent.target_position = spawn_position
			_set_state(State.RETURN_HOME)

func _execute_state(delta: float) -> void:
	match current_state:
		State.IDLE:
			speed = const_speed
			velocity.x = 0
			velocity.z = 0
			mesh_nps._play_anim("idle")
			_try_request_token()

			if not has_attack_token:
				has_attack_token = EnemyManager.request_attack_token(self)

		State.CHASE:
			speed = const_speed
			mesh_nps._play_anim("walk")
			nav_agent.target_position = player.global_position

			if not has_attack_token:
				has_attack_token = EnemyManager.request_attack_token(self)
			if nav_agent.is_navigation_finished():
				velocity.x = 0
				velocity.z = 0
			else:
				_move_along_path()
			_try_request_token()
		State.CIRCLE:
			speed = const_speed * circle_speed_mult
			mesh_nps._play_anim("walk")

			var desired_angle = EnemyManager.get_flank_angle(self)
			_circle_angle = lerp_angle(_circle_angle, desired_angle, delta * 1.5)

			var offset = Vector3(
				cos(_circle_angle) * circle_radius,
				0,
				sin(_circle_angle) * circle_radius
			)
			var circle_target = player.global_position + offset
			nav_agent.target_position = circle_target

			if not nav_agent.is_navigation_finished():
				_move_along_path()
			else:
				velocity.x = 0
				velocity.z = 0

			_face_target(player.global_position)
			_try_request_token()
			if has_attack_token:
				_set_state(State.RUN_ATTACK)

		State.RUN_ATTACK:
			speed = const_speed * 2
			mesh_nps._play_anim("run_attack")
			nav_agent.target_position = player.global_position
			_move_along_path()

		State.ATTACK:
			velocity.x = 0
			velocity.z = 0
			mesh_nps._play_anim("run_attack_new")
			_face_target(player.global_position)

		State.REGROUP:
			_face_target(player.global_position)
			
			var retreat_dir = player.global_position.direction_to(global_position)
			retreat_dir.y = 0
			retreat_dir = retreat_dir.normalized()
			
			speed = const_speed * 1.5
			
			velocity.x = retreat_dir.x * speed
			velocity.z = retreat_dir.z * speed
			
			mesh_nps._play_anim("walk")
			
			regroup_timer -= delta
			if regroup_timer <= 0:
				velocity.x = 0
				velocity.z = 0
				_set_state(State.CIRCLE)

		State.HURT:
			velocity.x = 0
			velocity.z = 0
			mesh_nps._play_anim("hurt")
			hurt_timer -= delta
			_set_state(State.REGROUP)

		State.SEARCH_WALK:
			speed = const_speed
			mesh_nps._play_anim("walk")
			if nav_agent.is_navigation_finished():
				velocity.x = 0
				velocity.z = 0
				_set_state(State.SEARCH_LOOK)
				look_timer = look_around_time
			else:
				_move_along_path()

		State.SEARCH_LOOK:
			velocity.x = 0
			velocity.z = 0
			mesh_nps._play_anim("search")
			look_timer -= delta
			if look_timer <= 0:
				_set_random_search_target()
				_set_state(State.SEARCH_WALK)

		State.RETURN_HOME:
			speed = const_speed
			mesh_nps._play_anim("walk")
			if nav_agent.is_navigation_finished():
				velocity.x = 0
				velocity.z = 0
				global_rotation = spawn_rotation
				_set_state(State.IDLE)
			else:
				nav_agent.target_position = spawn_position
				_move_along_path()

		State.FLY_BACK:
			velocity.x = fly_direction.x * fly_speed
			velocity.z = fly_direction.z * fly_speed
			mesh_nps._play_anim("fly")
			if back_raycast.is_colliding():
				velocity = Vector3.ZERO
				is_dead = true
				_set_state(State.DEAD)
				mesh_nps._play_anim("dead")
				return
			fly_timer -= delta
			if fly_timer <= 0:
				fly_speed = move_toward(fly_speed, 0.0, fly_friction * delta)
				if fly_speed <= 0.0:
					velocity = Vector3.ZERO
					is_dead = true
					_set_state(State.DEAD)
					mesh_nps._play_anim("default_dead")

		State.DEAD:
			velocity.x = 0
			velocity.z = 0


func _set_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state

func _release_token() -> void:
	if has_attack_token:
		EnemyManager.release_attack_token(self)
		has_attack_token = false
		attack_cooldown_timer = attack_cooldown
func _try_request_token() -> void:
	if not has_attack_token and attack_cooldown_timer <= 0 and can_take_token:
		has_attack_token = EnemyManager.request_attack_token(self)

func _move_along_path() -> void:
	var next_path_pos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_pos)
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	_face_target(next_path_pos)

func _set_random_search_target() -> void:
	var random_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	var random_distance = randf_range(5.0, search_radius)
	nav_agent.target_position = global_position + (random_direction * random_distance)

func _face_target(target_pos: Vector3) -> void:
	var look_pos = Vector3(target_pos.x, global_position.y, target_pos.z)
	if global_position.distance_squared_to(look_pos) > 0.001:
		look_at(look_pos, Vector3.UP)

func take_parry() -> void:
	if is_stanned:
		return
	bash += mod_bash_cap
	velocity.x = 0
	velocity.z = 0
	_release_token()
	
	if bash >= mod_bash_cap:
		_apply_stan() 
		return
	

	hurt_timer = player.bash_longer
	_set_state(State.HURT)
	
	if bash >= mod_bash_cap:
		_apply_stan()
		return
	

	hurt_timer = player.bash_longer
	_set_state(State.HURT)

func _apply_stan() -> void:
	_release_token()
	is_stanned = true
	_set_state(State.STUNNED)
	mesh_nps._play_anim("stan")
	var duration: float = player.bash_longer if player and "bash_longer" in player else 2.0
	await get_tree().create_timer(duration).timeout
	bash = 0
	is_stanned = false
	regroup_timer = regroup_duration
	_set_state(State.REGROUP)

func _on_bash_ares_area_entered(_area: Area3D) -> void:
	player.play_shild_clang()
	if can_bash and not is_stanned:
		can_bash = false
		if player and "bash_point" in player:
			bash += player.bash_point
			if bash >= mod_bash_cap:
				_apply_stan()
				can_bash = true
				return

			_release_token()
			hurt_timer = 1.0
			_set_state(State.HURT)
		await get_tree().create_timer(0.5).timeout
		can_bash = true

func _on_shot_area_area_entered(_area: Area3D) -> void:
	if player and player.has_method("_take_damag"):
		player._take_damag(damage)

func set_target_glow(status: String) -> void:
	match status:
		"yellow":
			targer_color.visible = true
			targer_color.light_color = Color(1.0, 1.0, 0.0)
		"red":
			targer_color.visible = true
			targer_color.light_color = Color(1.0, 0.0, 0.0)
		"none":
			targer_color.visible = false

func take_damage(amount: int) -> void:
	var midle_damag = randi_range((amount - randi_range(1, 25)), amount)
	Hp -= midle_damag
	if damage_ui_plaece.get_child_count() > 0:
		return
	var scena_ins = inctanse_damage_lable.instantiate()
	damage_ui_plaece.add_child(scena_ins)
	scena_ins._play_anim_damage_poin_take(midle_damag)

func _you_got_shot(shooter_position: Vector3) -> void:
	if is_dead:
		return
	_face_target(shooter_position)
	fly_direction = shooter_position.direction_to(global_position)
	fly_direction.y = 0
	fly_direction = fly_direction.normalized()
	fly_speed = push_force
	fly_timer = 2.0
	_release_token()
	_set_state(State.FLY_BACK)

func lock_movement() -> void:
	is_locked_by_anim = true

func unlock_movement() -> void:
	is_locked_by_anim = false
