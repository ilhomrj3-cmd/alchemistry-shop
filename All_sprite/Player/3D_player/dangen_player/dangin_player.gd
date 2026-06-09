extends CharacterBody3D

@onready var anim_tree: AnimationTree = $charactery/main_character/Player_AnimationTree
@onready var anim_state: AnimationNodeStateMachinePlayback
@onready var mesh_rotate = $charactery
@onready var warning_panel = $CameraPivot/SpringArm3D/Camera3D/CanvasPlayer/warning_panel
@onready var cam_pivot = $CameraPivot
@onready var spring_arm = $CameraPivot/SpringArm3D
@onready var shild_cland = $SFX/sheld/shild_clang

var shield_equipped := false
var is_blocking := false
@export var bash_longer = 5.0
@export var bash_point = 5.0
@export var base_speed := 2.0
@export var run_speed := 7.0
@export var shield_speed := 3.5
@export var shield_run_speed := 6.5
@export var Hp = 300
@export var mouse_sensitivity := 0.003

var dont_move_okey = false
var SPEED := 4.0



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 
	anim_tree.active = true
	anim_state = anim_tree.get("parameters/StateMachine/playback")

func _unhandled_input(event):
	if event is InputEventMouseMotion and not dont_move_okey: 
		cam_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
		spring_arm.rotate_x(-event.relative.y * mouse_sensitivity)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/3, PI/4)

func _input(event):
	if event.is_action_pressed("ui_cancel") and not dont_move_okey:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event.is_action_pressed("shield_toggle") and not dont_move_okey:
		shield_equipped = !shield_equipped
		is_blocking = false 

	if shield_equipped:
		if event.is_action_pressed("block") and not dont_move_okey:
			is_blocking = true
		elif event.is_action_released("block") and not dont_move_okey:
			is_blocking = false

func _physics_process(delta):
	var input = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)
	
	var is_running = Input.is_action_pressed("ui_run")


	if is_running and input.y > 0 and not dont_move_okey:
		input.y = 0

	mesh_rotate.global_transform.basis = cam_pivot.global_transform.basis
	mesh_rotate.rotation.x = 0
	mesh_rotate.rotation.z = 0

	if is_blocking and not dont_move_okey:
		velocity = Vector3.ZERO
		update_animation(Vector2.ZERO)
		move_and_slide()
		return


	var forward = -mesh_rotate.global_transform.basis.z
	var right = mesh_rotate.global_transform.basis.x 


	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()


	var direction = (forward * -input.y + right * input.x)

	if shield_equipped:
		SPEED = shield_run_speed if is_running else shield_speed
	else:
		SPEED = run_speed if is_running else base_speed
	if dont_move_okey:
		velocity.x = 0
		velocity.z = 0
	elif direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	update_animation(input)

	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0

	move_and_slide()

func update_animation(input: Vector2):
	if is_blocking and not dont_move_okey:
		anim_state.travel("block")
		return

	var is_running := Input.is_action_pressed("ui_run")

	if input == Vector2.ZERO:
		if shield_equipped:
			anim_state.travel("idle_with_shield")
		else:
			anim_state.travel("idle")
		return

	if abs(input.y) >= abs(input.x):
		if input.y < 0: 
			if is_running  and not dont_move_okey:
				if shield_equipped:
					anim_state.travel("run_with_shild_forward")
				else:
					anim_state.travel("run_forward")
			else:
				if shield_equipped:
					anim_state.travel("walk_with_shild_forward")
				else:
					anim_state.travel("walk_forward")
		else: # Назад 
			if not is_running:
				if shield_equipped and not dont_move_okey:
					anim_state.travel("walk_with_shild_backward")
				else:
					anim_state.travel("walk_backward")
	else:
		if input.x > 0: # Вправо
			if shield_equipped and not dont_move_okey:
				anim_state.travel("walk_with_shild_right")
			else:
				anim_state.travel("walk_right")
		else: # Влево
			if shield_equipped and not dont_move_okey:
				anim_state.travel("walk_with_shild_left")
			else:
				anim_state.travel("walk_left")

func _take_damag(damage: int):
	var min_dmg = damage - 6
	var max_dmg = damage
	var damage_take = randf_range(min_dmg, max_dmg)
	Hp -= damage_take
	print_debug(Hp)
func play_shild_clang():
	shild_cland.play()
	await get_tree().create_timer(1).timeout
	shild_cland.stop()
