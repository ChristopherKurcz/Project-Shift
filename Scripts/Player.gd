extends CharacterBody2D

# constants
const MAX_RUN_SPEED = 70
const ACCELERATION = 200
const DEACCELERATION = 250
const AIR_ACCELERATION = 150
const AIR_DEACCELERATION = 75
const GRAVITY = 200
const JUMP_GRAVITY = 100 
const MAX_FALL_SPEED = 650
const JUMP_FORCE = 65 
const WALL_JUMP_FORCE = 40
const MAX_WALL_SLIDE_SPEED = 40
const IMPACT_DEATH_SPEED = 180
# states
enum body_states{SOLID, PHASE, DEAD}
# variables
var input_axis
var collision_normal = Vector2.UP
var slide_collision = null
var collision_angle = 0.0
var prev_real_velocity = Vector2.ZERO
var body_state = body_states.SOLID
var wall_sliding
var falling
var on_floor
var was_on_floor
var valid_wall_angle
var in_soft_area = false
# times
var coyote_time = 0.05
var jump_timer = 0.0
# nodes
@onready var Sprite = $Sprite2D
@onready var FloorRaycast = $FloorRaycast
# debug
var exit_on_escape = true



func _process(_delta):
	process_input()
	if exit_on_escape and Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()


func process_input():
	input_axis = Input.get_axis("move_left", "move_right")
	
	if Input.is_action_pressed("phase"):
		body_state = body_states.PHASE
	else:
		if not in_soft_area:
			body_state = body_states.SOLID


func _physics_process(delta):
	process_collisions()
	process_states()
	process_timers(delta)
	if body_state != body_states.DEAD:
		process_player_movement(delta)
	process_sprite()
	process_previous()


func process_collisions():
	if get_slide_collision_count() > 0:
		slide_collision = get_slide_collision(0)
		collision_normal = slide_collision.get_normal()
		collision_angle = rad_to_deg(slide_collision.get_angle())
		if collision_angle <= 1:
			floor_snap_length = 0
		else:
			floor_snap_length = 4.5
		#if prev_real_velocity.length() > IMPACT_DEATH_SPEED and prev_real_velocity.dot(collision_normal.normalized()) <= 0:
		#	body_state = body_states.DEAD
	
	on_floor = true if FloorRaycast.is_colliding() else false
	valid_wall_angle = true if (collision_angle > 89.0 and collision_angle < 91.0) else false
	wall_sliding = true if (valid_wall_angle and is_on_wall() and get_wall_normal() == input_axis * Vector2.LEFT) else false


func process_states():
	match body_state:
		body_states.SOLID:
			set_collision_mask_value(2,true)
			FloorRaycast.set_collision_mask_value(2,true)
		body_states.PHASE:
			set_collision_mask_value(2,false)
			FloorRaycast.set_collision_mask_value(2,false)


func process_player_movement(delta):
	# determine acceleration
	var _acceleration = get_acceleration()
	
	# determine velocity
	if input_axis and on_floor and slide_collision != null and collision_angle <= 45.1:
		var targetAngle = snapped((rad_to_deg(collision_normal.normalized().rotated(deg_to_rad(90)).angle())),5)
		var direction = Vector2.RIGHT.rotated(deg_to_rad(targetAngle))
		var target = direction * input_axis * MAX_RUN_SPEED
		velocity = velocity.move_toward(target, _acceleration * delta)
	if input_axis:
		velocity.x = move_toward(velocity.x, input_axis * MAX_RUN_SPEED, _acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, _acceleration * delta)
	
	# Add gravity
	if not is_on_floor():
		if was_on_floor:
			print("bruh")
			velocity.y = prev_real_velocity.y
			was_on_floor = false
		var _gravity = get_gravity()
		velocity.y += _gravity * delta
		if falling and velocity.y >= MAX_FALL_SPEED:
			velocity.y = MAX_FALL_SPEED
		if falling and wall_sliding and velocity.y >= MAX_WALL_SLIDE_SPEED:
			velocity.y = MAX_WALL_SLIDE_SPEED
	elif get_real_velocity().y >= 0:
		var _gravity = get_gravity()
		velocity.y += _gravity * delta
	
	# Handle Jump
	if Input.is_action_just_pressed("jump"):
		if (on_floor or (jump_timer <= coyote_time)):
			falling = false
			if (input_axis * Vector2.RIGHT).dot(collision_normal.normalized()) > 0:
				velocity += collision_normal.normalized() * JUMP_FORCE
			else :
				velocity.y = -JUMP_FORCE + min(get_real_velocity().y * 0.8,0)
		elif is_on_wall():
			falling = false
			var wall_normal = get_wall_normal()
			velocity.x = wall_normal.x * WALL_JUMP_FORCE
			velocity.y = min(-JUMP_FORCE*0.9, -JUMP_FORCE*0.9 + get_real_velocity().y)
	
	if (Input.is_action_just_released("jump") and not falling) or (velocity.y >= 0):
		falling = true
	
	move_and_slide()


func get_acceleration():
	if input_axis:
		return ACCELERATION if is_on_floor() else AIR_ACCELERATION
	else:
		return DEACCELERATION if is_on_floor() else AIR_DEACCELERATION


func get_gravity():
	return GRAVITY if falling else JUMP_GRAVITY


func process_timers(delta):
	if not falling:
		jump_timer += coyote_time
	
	if is_on_floor():
		jump_timer = 0.0
	else:
		jump_timer += delta


func process_sprite():
	# color
	match body_state:
		body_states.PHASE:
			Sprite.self_modulate = Color("539987")
		body_states.SOLID:
			Sprite.self_modulate = Color("f1e3d3")
	
	# frame
	var real_velocity = get_real_velocity()
	if not on_floor and not wall_sliding and real_velocity.y < -5:
		Sprite.frame = 1
	elif not on_floor and not wall_sliding and real_velocity.y > 5:
		Sprite.frame = 2
	elif wall_sliding:
		Sprite.frame = 0
	else:
		Sprite.frame = 0
	
	# flip
	if real_velocity.x < -5:
		Sprite.flip_h = true
	if real_velocity.x > 5:
		Sprite.flip_h = false


func process_previous():
	prev_real_velocity = get_real_velocity()
	was_on_floor = is_on_floor()


func die():
	body_state = body_states.DEAD


func _on_soft_collision_check_body_entered(_body):
	in_soft_area = true

func _on_soft_collision_check_body_exited(_body):
	in_soft_area = false
