# LEVEL 2 SCRIPT
extends Node2D

@onready var player = $Player

@onready var lasers: Node = $Lasers
@onready var asteroids: Node = $Asteroids
@onready var spawn_timer: Timer = $MeteorSpawner/Timer

var asteroid_scene = preload(
	"res://Scenes/Level Scenes/meteors.tscn"
)


func _ready() -> void:

	# Turn ON stretch
	var window = get_window()

	window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS

	window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND

	# Level 2 player setup
	player.enable_camera = false

	# Turn camera OFF immediately
	if player.camera:
		player.camera.enabled = false

	player.player_force = 900.0

	player.can_shoot = true

	player.set_movement_mode(
		player.MovementMode.SOLID
	)

	player.connect(
		"laser_shot",
		_on_player_laser_shot
	)

	randomize()

	spawn_timer.timeout.connect(
		_on_spawn_timer_timeout
	)

	spawn_timer.wait_time = 0.7

	spawn_timer.start()


func _on_player_laser_shot(laser: Area2D) -> void:

	lasers.add_child(laser)


func _on_spawn_timer_timeout() -> void:

	var screen_size = get_viewport_rect().size

	var spawn_pos := Vector2.ZERO
	var dir := Vector2.ZERO

	var side = randi() % 4

	match side:

		# TOP
		0:
			spawn_pos = Vector2(
				randf_range(-200, screen_size.x + 200),
				-150
			)

			dir = Vector2(
				randf_range(-0.5, 0.5),
				1
			)

		# BOTTOM
		1:
			spawn_pos = Vector2(
				randf_range(-200, screen_size.x + 200),
				screen_size.y + 150
			)

			dir = Vector2(
				randf_range(-0.5, 0.5),
				-1
			)

		# LEFT
		2:
			spawn_pos = Vector2(
				-150,
				randf_range(-200, screen_size.y + 200)
			)

			dir = Vector2(
				1,
				randf_range(-0.5, 0.5)
			)

		# RIGHT
		3:
			spawn_pos = Vector2(
				screen_size.x + 150,
				randf_range(-200, screen_size.y + 200)
			)

			dir = Vector2(
				-1,
				randf_range(-0.5, 0.5)
			)

	spawn_asteroid(
		spawn_pos,
		Asteroid.AsteroidSize.LARGE,
		dir.normalized()
	)


func _on_asteroid_exploded(pos, size) -> void:

	match size:

		Asteroid.AsteroidSize.LARGE:

			for i in range(2):

				spawn_split_asteroid(
					pos,
					Asteroid.AsteroidSize.MEDIUM
				)

		Asteroid.AsteroidSize.MEDIUM:

			for i in range(2):

				spawn_split_asteroid(
					pos,
					Asteroid.AsteroidSize.SMALL
				)

		Asteroid.AsteroidSize.SMALL:
			pass


func spawn_split_asteroid(pos, size) -> void:

	var random_dir = Vector2(
		randf_range(-1, 1),
		randf_range(-1, 1)
	).normalized()

	spawn_asteroid(
		pos,
		size,
		random_dir
	)


func spawn_asteroid(pos, size, dir) -> void:

	var asteroid = asteroid_scene.instantiate()

	asteroid.global_position = pos
	asteroid.size = size
	asteroid.direction = dir

	asteroid.connect(
		"exploded",
		_on_asteroid_exploded
	)

	asteroids.add_child(asteroid)
