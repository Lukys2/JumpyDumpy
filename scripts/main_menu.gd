extends Control
@onready var transition_fade = $"../Transition"
var level1 = preload("res://scenes/level_1.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_play_button_pressed() -> void:
	transition_fade.play("fade_out")
	
func _on_transition_animation_finished(_anim_name):
	get_tree().change_scene_to_packed(level1)
