extends CharacterBody2D

@export var speed = 50
@export var run_speed = 100
@export var block_duration: float = 2.0

@onready var anim = $AnimationPlayer
var finish_block = false
var is_blocking = false
var last_direction = Vector2.DOWN 

func _physics_process(_delta):
	if finish_block:
		return
	var direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	if Input.is_action_just_pressed("block"):
		start_block()
		return

	if direction != Vector2.ZERO:
		last_direction = direction
		var current_speed = run_speed if Input.is_action_pressed("run") else speed
		velocity = direction * current_speed
		play_animation("walk", direction)
	else:
		velocity = Vector2.ZERO
		play_animation("idle", last_direction)
		
	move_and_slide()

func start_block():
	is_blocking = true
	finish_block = true
	velocity = Vector2.ZERO

	play_animation("block", last_direction)
	await anim.animation_finished
	finish_block = false
	await get_tree().create_timer(block_duration).timeout
	is_blocking = false

func play_animation(prefix: String, direction: Vector2):
	var suffix = ""
	
	if abs(direction.x) > abs(direction.y):
		suffix = "_right" if direction.x > 0 else "_left"
	else:
		suffix = "_down" if direction.y > 0 else "_up"
	
	var anim_name = prefix + suffix
	
	if anim.current_animation != anim_name:
		anim.play(anim_name)
