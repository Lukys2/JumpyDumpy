extends Node2D

@onready var transition = $LOGIKA/Transition

@onready var bgmusic = $"LOGIKA/Sfx&Music/BackgroundMusic"

func _ready():
	bgmusic.play()
	transition.play("fade_in")
