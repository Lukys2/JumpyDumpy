extends CharacterBody2D

var speed = 300

var min_jump_power = -250
var max_jump_power = -750
var min_jump_x = 100
var max_jump_x = 500

var is_dying := false

var charge_time := 0.0
var max_charge_time := 0.5
var charging := false

var jump_direction := 0

var is_wall_clinging := false
var wall_normal := Vector2.ZERO

@onready var player_animations = $Sprite2D
@onready var ray_left: RayCast2D = $RayCastLeft
@onready var ray_right: RayCast2D = $RayCastRight
@onready var death_zone_start = $"../../MAPA/DeathZoneStart"


func _physics_process(_delta):
	if is_dying or not is_inside_tree():
		return  # přeskočíme fyziku, dokud nejsme plně připojeni

	# --- GRAVITY ---
	if not is_on_floor():
		velocity += get_gravity() * _delta
	
	# --- HORIZONTAL MOVEMENT ---
	if is_on_floor() and not charging:
		var direction := Input.get_axis("left", "right")
		velocity.x = direction * speed
	elif charging:
		velocity.x = 0  # hráč se nesmí hýbat při nabíjení

	# --- JUMP INPUT ---
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			start_charging()

	# --- CHARGE JUMP ---
	if charging:
		charge_time += _delta
		charge_time = min(charge_time, max_charge_time)
		
	if Input.is_action_just_released("jump") and charging:
		do_jump()
		
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		
	# --- WALL CLING ---
	handle_wall_cling()

	# --- MOVE ---
	move_and_slide()
	


	# --- ANIMATIONS ---
	update_animations()
	
	
	var cam = $Camera2D
	
	if cam == null or not is_inside_tree():
		return
	
	var cam_x = cam.get_screen_center_position().x
	var view_rect = get_viewport_rect()

	if view_rect == null:
		return

	var view_width = get_viewport_rect().size.x / cam.zoom.x
	var limit_left = cam_x - (view_width / 2)
	var limit_right = cam_x + (view_width / 2)
	
	position.x = clamp(position.x, limit_left + 25, limit_right - 25)
		
func start_charging():
	charging = true
	charge_time = 0.0
	var direction := Input.get_axis("left", "right")
	jump_direction = sign(direction)
	player_animations.play("charge")


func do_jump():
	var t = charge_time / max_charge_time
	velocity.y = lerp(min_jump_power, max_jump_power, t)
	velocity.x = jump_direction * lerp(min_jump_x, max_jump_x, t)
	charging = false
	player_animations.play("jump")


func wall_jump():
	velocity.y = -600
	velocity.x = 400 * -wall_normal.x  # odraz od stěny
	is_wall_clinging = false
	player_animations.play("jump")


func handle_wall_cling():
	# na zemi wall hang nechceme
	if is_on_floor():
		is_wall_clinging = false
		return

	var touching_wall := false

	if ray_left.is_colliding():
		touching_wall = true
		wall_normal = Vector2.RIGHT
	elif ray_right.is_colliding():
		touching_wall = true
		wall_normal = Vector2.LEFT

	is_wall_clinging = touching_wall

	# zpomalení pádu po zdi
	if is_wall_clinging and velocity.y > 0:
		velocity.y = min(velocity.y, 110)

	# wall jump
	if Input.is_action_just_pressed("jump") and is_wall_clinging:
		velocity.y = -600
		velocity.x = 430 * wall_normal.x
		is_wall_clinging = false
		player_animations.play("jump")

	

func update_animations():
	# --- FLIP SPRITE ---
	if velocity.x > 0:
		player_animations.flip_h = false
		player_animations.offset.x = 3
	elif velocity.x < 0:
		player_animations.flip_h = true
		player_animations.offset.x = -3.5

	# --- ANIMATION STATE ---
	if charging:
		return
	elif is_on_floor():
		if velocity.x == 0:
			player_animations.play("idle")
		else:
			player_animations.play("run")
	elif is_wall_clinging and velocity.y >= 0:
		player_animations.play("hang")
	elif velocity.y > 0:
		player_animations.play("fall")
	# jump animace je nastavena při skoku


func _on_death_zone_start_body_entered(_body):
	if is_dying: return
	is_dying = true
	set_physics_process(false)
	process_mode = PROCESS_MODE_DISABLED
	get_tree().call_deferred("reload_current_scene")
