extends CharacterBody3D

@export var targets: Array[Node3D]
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@export var speed: int
@export var sex: String
@onready var animation_emogi_nps: AnimationPlayer = $Animation_emogi_nps

var Male = preload("res://All_sprite/NPS/Female/Female_main.tscn")
var Female = preload("res://All_sprite/NPS/male/Male_main.tscn")
var anim_tree: AnimationTree


var target_idx = 0
var is_buying = false
var up = false
var leave_idx = -1
enum State { GO_TO_SHOP, SEARCH_ITEM, GO_TO_CASHIER, AT_CASHIER, LEAVING, WAITING } # это состоянии нпс
var current_state = State.GO_TO_SHOP
var target_shelf = null # к какому шкафу идти?
var inventory = preload("res://Scena/Managers/Inv_managers/INV/Nps_Inv.tres")
var nps_inventory = inventory.duplicate()

func _ready():
	sex = "Male" if randf() > 0.5 else "Female"
	var instance
	if sex == "Male":
		instance = Female.instantiate()
	else:
		instance = Male.instantiate()
	add_child(instance)
	anim_tree = instance.find_child("all_nps_anim", true, false)

	if anim_tree:
		_update_target()

func _physics_process(_delta):
	if anim_tree == null:
		return
	if not is_on_floor():
		velocity.y -= 80 * _delta
	#ПРЫЖОК
	if $CollisionShape3D/can_up_RayCast3D.is_colliding() and is_on_floor():
		velocity.y = 20

	# все состоянии
	match current_state:
		State.GO_TO_SHOP:
			_logic_go_to_shop()
		State.SEARCH_ITEM:
			_logic_search_item_movement()
		State.GO_TO_CASHIER:
			_logic_pay()
		State.LEAVING:
			_logic_leave()
		State.WAITING:
			velocity.x = 0
			velocity.z = 0
		State.AT_CASHIER:
			velocity.x = 0
			velocity.z = 0
	_update_animation_parameters()
	move_and_slide()

	
	if velocity.length() > 0.1:
		var target_v = Vector3(velocity.x, 0, velocity.z)
		if target_v.length() > 0.001:
			var target_dir = target_v.normalized()
			var target_basis = Basis.looking_at(target_dir, Vector3.UP)
			global_basis = global_basis.slerp(target_basis, 0.1)

func _logic_go_to_shop():
	if target_idx < targets.size():
		nav_agent.target_position = targets[target_idx].global_position
		
		_move_to_target()
		
		if nav_agent.is_navigation_finished():
			target_idx += 1
	else:
		current_state = State.SEARCH_ITEM

func _logic_search_item_movement():
	if target_shelf == null:
		_pick_random_shelf()
		return
		
	nav_agent.target_position = target_shelf.interaction_marker.global_position
	_move_to_target()
	
	if nav_agent.is_navigation_finished():
		_interact_with_shelf()


func _move_to_target():
	var next_path_pos = nav_agent.get_next_path_position()
	var dir = global_position.direction_to(Vector3(next_path_pos.x, global_position.y, next_path_pos.z))
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

func _update_target():
	if targets.size() > 0:
		nav_agent.target_position = targets[target_idx].global_position

func _logic_search_item():
	if target_shelf == null:
		_pick_random_shelf()
	if nav_agent.is_navigation_finished() and target_shelf != null:
		_interact_with_shelf()

func _pick_random_shelf():

	var available_shelves = []
	for s in GlScript.active_shelves:
		if not s.is_empty():
			available_shelves.append(s)

	if available_shelves.is_empty():
		var has_items = nps_inventory.items.any(func(item): return item != null)
		current_state = State.GO_TO_CASHIER if has_items else State.LEAVING
		leave_idx = -1
		return

	target_shelf = available_shelves.pick_random()
	nav_agent.target_position = target_shelf.interaction_marker.global_position
	current_state = State.SEARCH_ITEM

func _decide_next_step():
	var has_items = nps_inventory.items.any(func(item): return item != null)
	
	if has_items and randf() > 0.5:
		current_state = State.GO_TO_CASHIER
	else:
		current_state = State.SEARCH_ITEM
func _interact_with_shelf():
	var playback = anim_tree["parameters/StateMachine/playback"]
	if target_shelf:
		var dir = (target_shelf.global_position - global_position)
		dir.y = 0
		dir = dir.normalized()
		var target_basis = Basis.looking_at(dir, Vector3.UP)
		global_basis = target_basis
		
	is_buying = true
	playback.travel("buys")

	current_state = State.WAITING

	var wait_time = randf_range(3.0, 4.0)
	await get_tree().create_timer(wait_time).timeout

	is_buying = false
	
	if randf() > 0.5: 
		var wanted_count = randi_range(1, 8)
		var shelf_items = target_shelf.items 
		var shelf_size = shelf_items.size()
		var taken_count = 0

		var current_idx = randi() % shelf_size
		var attempts = 0 
		var max_attempts = shelf_size * 2

		while taken_count < wanted_count and attempts < max_attempts:
			
			var item = shelf_items[current_idx]
			if item != null:
				var is_good_price = true
				if randf() >= 0.5:
					animation_emogi_nps.play("hmm")
				else:
					animation_emogi_nps.play("hmm")
				if GlScript.get_item_price(item.Id) > item.market_price:
					# pассчитываем "наглость" игрока (например, цена 150 при рынке 100 = 1.5)
					var greed_factor = float(GlScript.get_item_price(item.Id)) / float(item.market_price)
					
					var buy_chance = remap(greed_factor, 1.0, 2.0, 1, 0.1)
					buy_chance = clamp(buy_chance, 0.0, 1)
					
					if randf() > buy_chance:
						is_good_price = false

						wanted_count -= 1 
						animation_emogi_nps.play("shock")
						
						print_debug("NPC: Слишком дорого за ", item.name, "! Больше брать не буду.")

				# Если цена устроила или ниже рыночного
				if is_good_price:
					for n in range(nps_inventory.items.size()):
						if nps_inventory.items[n] == null:
							nps_inventory.items[n] = item
							shelf_items[current_idx] = null
							taken_count += 1
							break
			if wanted_count <= 0:
				break
			current_idx = (current_idx + randi_range(1, 5)) % shelf_size
			attempts += 1
		
		target_shelf.update_shelf_visuals()
		if taken_count == 0 and wanted_count <= 0:
			print_debug("Ухожу из этого дорогого магазина!")
			GlScript.player_shop.warning_panel._new_warning("prices are too high")
			var ran = randf()
			if ran <= 0.3:
				animation_emogi_nps.play("angre")
			elif ran > 0.3 and ran <= 0.6:
				animation_emogi_nps.play("poker_face_2")
			else:
				animation_emogi_nps.play("poker_face")
				
			current_state = State.LEAVING
			return
		print_debug("закончил выбор. Взято предметов: ", taken_count)

	target_shelf = null
	_decide_next_step()

func _logic_pay():
	var cashier = get_tree().get_first_node_in_group("cashier")
	if not cashier: return
	
	var queue_pos = cashier.join_queue(self)
	nav_agent.target_position = queue_pos
	_move_to_target()
	
	if nav_agent.is_navigation_finished():
		current_state = State.AT_CASHIER
		if cashier.current_customers.find(self) == 0:
			var has_items = nps_inventory.items.any(func(item): return item != null)
			
			if has_items:
				cashier.process_payment(self)

func update_queue_position():
	_logic_pay()

func _logic_leave():
	if leave_idx == -1:
		leave_idx = targets.size() - 1
	
	if leave_idx >= 0:
		nav_agent.target_position = targets[leave_idx].global_position
		_move_to_target()
		if nav_agent.is_navigation_finished():
			leave_idx -= 1
			if leave_idx < 0:
				queue_free()
	else:
		queue_free()

func _update_animation_parameters():
	if is_buying:
		return
	var playback = anim_tree["parameters/StateMachine/playback"]
	var current_node = playback.get_current_node()
	
	if current_node == "buys":
		if playback.is_playing(): 
			return
	var is_moving = velocity.length() > 0.1
	
	if is_moving:
		playback.travel("walk_1")
	else:
		if current_state == State.AT_CASHIER:
			playback.travel("idel_1")# ожидание у кассы
		else:
			playback.travel("idel_1")
func _get_nps_state():
	return current_state
	
