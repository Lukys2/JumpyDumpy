extends CharacterBody2D


var speed = 300

var min_jump_power = -250
var max_jump_power = -900
var min_jump_x = 100
var max_jump_x = 500

var charge_time := 0.0
var max_charge_time := 0.5
var charging := false

var jump_direction := 0

var is_wall_clinging := false
var wall_normal := Vector2.ZERO

@onready var player_animations = $Sprite2D
@onready var wall_hang_check = $WallHangCheck



func _physics_process(_delta):
	
	if not is_on_floor():
		velocity += get_gravity() * _delta
	
	if is_on_floor() and not charging:	
		player_animations.play("run")
		var direction := Input.get_axis("left", "right")
		velocity.x = direction * speed
	if velocity.x == 0 and is_on_floor() and not charging:
		player_animations.play("idle")

	if Input.is_action_just_pressed("jump") and is_on_floor():
		charging = true
		charge_time = 0.0
		player_animations.play("charge")
		var direction := Input.get_axis("left", "right")
		if direction != 0:
			jump_direction = sign(direction)
		else:
			jump_direction = 0
		jump_direction = sign(direction)
		
	if charging:
		charge_time += _delta
		charge_time = min(charge_time, max_charge_time)
		
	if Input.is_action_just_released("jump") and charging:
		player_animations.play("jump")
		var t = charge_time / max_charge_time
		velocity.y = lerp(min_jump_power, max_jump_power, t)
		velocity.x = jump_direction * lerp(min_jump_x, max_jump_x, t)
		charging = false
		
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	if velocity.x > 0:
		player_animations.flip_h = false
		player_animations.offset.x = 3
	elif velocity.x < 0:
		player_animations.flip_h = true
		player_animations.offset.x = -3.5


	if velocity.y > 0:
		player_animations.play("fall")
		
	if not charging:
		move_and_slide()
		
#		WALL JUMP
	if not is_on_floor():
		var touching_wall = false
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var normal = collision.get_normal()
			
			if abs(normal.y) < 0.2:
				touching_wall = true
				wall_normal = normal
				if velocity.y > 0:
					velocity.y = min(velocity.y, 110)  # nebo 0 pro okamžité přilepení
					
		is_wall_clinging = touching_wall
	else:
		is_wall_clinging = false

	# WALL JUMP
	if Input.is_action_just_pressed("jump") and is_wall_clinging:
		velocity.y = -600
		velocity.x = 400 * sign(wall_normal.x)  # vždy správný směr
		is_wall_clinging = false
		player_animations.play("jump")

	# WALL HANG ANIMATION
	if is_wall_clinging and velocity.y >= 0 and not is_on_floor():
		player_animations.play("hang")
		
