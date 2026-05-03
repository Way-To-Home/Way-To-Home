extends Area2D
class_name Asteroid

signal exploded(pos, size)

enum AsteroidSize {
	LARGE,
	MEDIUM,
	SMALL
}

@onready var explosion: GPUParticles2D = $Explosion

@export var destroy_particle: PackedScene
@export var size: AsteroidSize = AsteroidSize.LARGE

# Movement
var speed: float = 0.0
var direction: Vector2 = Vector2.ZERO
var rotation_speed: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	randomize()

	# Random rotation at spawn
	rotation = randf_range(0.0, TAU)

	# ASTEROID SIZE SETUP
	match size:

		AsteroidSize.LARGE:
			speed = randf_range(200.0, 300.0)

			var large_variants = [
				{
					"tex": preload("res://Meteors/meteorGrey_big1.png"),
					"col": preload("res://resources/meteor_cshape_big1.tres")
				},
				{
					"tex": preload("res://Meteors/meteorGrey_big2.png"),
					"col": preload("res://resources/meteor_cshape_big2.tres")
				},
				{
					"tex": preload("res://Meteors/meteorGrey_big3.png"),
					"col": preload("res://resources/meteor_cshape_big3.tres")
				},
				{
					"tex": preload("res://Meteors/meteorGrey_big4.png"),
					"col": preload("res://resources/meteor_cshape_big4.tres")
				}
			]

			var choice = large_variants.pick_random()

			sprite.texture = choice["tex"]
			collision.shape = choice["col"]

			scale = Vector2(1.0, 1.0)

		AsteroidSize.MEDIUM:
			speed = randf_range(150.0, 250.0)

			var medium_variants = [
				preload("res://Meteors/meteorGrey_med1.png"),
				preload("res://Meteors/meteorGrey_med2.png")
			]

			sprite.texture = medium_variants.pick_random()

			collision.shape = preload(
				"res://resources/meteor_cshape_medium.tres"
			)

			scale = Vector2(0.8, 0.8)

		AsteroidSize.SMALL:
			speed = randf_range(250.0, 350.0)

			var small_variants = [
				preload("res://Meteors/meteorGrey_small1.png"),
				preload("res://Meteors/meteorGrey_small2.png")
			]

			sprite.texture = small_variants.pick_random()

			collision.shape = preload(
				"res://resources/meteor_cshape_small.tres"
			)

			scale = Vector2(0.6, 0.6)

	# Smooth rotation
	rotation_speed = randf_range(-2.0, 2.0)

	# If direction wasn't assigned
	if direction == Vector2.ZERO:
		direction = Vector2.DOWN


func _physics_process(delta: float) -> void:
	# Smooth movement
	position += direction * speed * delta

	# Smooth rotation
	rotation += rotation_speed * delta


func explode() -> void:
	emit_signal("exploded", global_position, size)

	# Detach explosion so it survives asteroid deletion
	explosion.reparent(get_tree().current_scene)

	explosion.global_position = global_position
	explosion.rotation = rotation
	explosion.emitting = true

	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
