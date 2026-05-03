extends Control
@onready var win_menu_music: AudioStreamPlayer2D = $"Win Menu Music"

func _ready() -> void:
	win_menu_music.play()
	# Turn OFF stretch
	var window = get_window()

	window.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_IGNORE



func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level Scenes/level_2.tscn")
