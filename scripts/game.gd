extends Node2D

@onready var transition = $Transition
@onready var player = $player

@onready var bgmusic = $"Sfx&Music/BackgroundMusic"

func _ready():
	bgmusic.play()
	transition.play("fade_in")
