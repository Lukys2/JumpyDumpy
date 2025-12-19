extends CanvasLayer

@export var player: Node2D

@export var start_color: Color = Color("#3a7bd5") # dole
@export var end_color: Color = Color("#0f2027")   # nahoře

@export var max_height := 500

@onready var rect := $BackGround


func _process(_delta):
	if not player:
		return

	# výška = čím víc nahoru, tím větší číslo
	var height = -player.global_position.y

	# přepočet na 0–1
	var t = clamp(height / max_height, 0.0, 1.0)

	# plynulá změna barvy
	rect.color = start_color.lerp(end_color, t)
