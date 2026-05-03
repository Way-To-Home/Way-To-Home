# LEVEL 1 SCRIPT
extends Node2D

@onready var player = $Player

@onready var game_background_music: AudioStreamPlayer2D = $"Player/Game Background Music"

@onready var timer: Timer = $Timer
@onready var timer_label: Label = $"CanvasLayer3/Control/Timer Label"

var time_left: int = 120


func _ready() -> void:

	# Turn OFF stretch
	var window = get_window()

	window.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_IGNORE

	# Level 1 player setup
	player.enable_camera = true

	player.player_force = 1500.0

	player.set_movement_mode(
		player.MovementMode.SLIPPERY
	)

	game_background_music.play()

	timer.start()


func _on_maze_body_entered(body: Node2D) -> void:

	game_background_music.stop()

	body.call_deferred("queue_free")

	get_tree().call_deferred(
		"change_scene_to_file",
		"res://Scenes/UI Scenes/game_over_panel.tscn"
	)


func _on_timer_timeout() -> void:

	time_left -= 1

	timer_label.text = str(time_left)

	if time_left <= 0:

		timer.stop()

		get_tree().change_scene_to_file(
			"res://Scenes/UI Scenes/game_over_panel_2.tscn"
		)
