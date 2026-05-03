extends Control
@onready var main_menu_music: AudioStreamPlayer2D = $"Main Menu Music"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_menu_music.play()
	var window = get_window()

	window.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_IGNORE


func _on_start_button_pressed() -> void:
	main_menu_music.stop()
	get_tree().change_scene_to_file("res://Scenes/Level Scenes/level_1.tscn")


func _on_about_button_pressed() -> void:
	print("About Button has been pressed :D")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
