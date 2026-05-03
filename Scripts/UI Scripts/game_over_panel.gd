extends Control
@onready var game_over_music: AudioStreamPlayer2D = $"Game Over Music"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_over_music.play()
