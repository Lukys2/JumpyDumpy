extends Node2D

@onready var transition = $Transition
@onready var cam1 = $"Level 1/Camera_lvl1"
@onready var cam2 = $"Level 2/Camera_lvl2"
@onready var player = $player
@onready var area1 = $"Level 1/Area_lvl1"
@onready var bgmusic = $"Sfx&Music/BackgroundMusic"

func _ready():
	bgmusic.play()
	transition.play("fade_in")
	cam1.make_current()



func _on_area_lvl_1_body_exited(_body):
	if player.velocity.y > 0:
		cam1.make_current()
	elif player.velocity.y < 0:
		cam2.make_current()
		
