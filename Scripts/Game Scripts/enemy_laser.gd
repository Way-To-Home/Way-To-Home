extends Area2D

@export var speed := 1000.0

@onready var sprite: Sprite2D = $Sprite2D

var direction := Vector2.UP


func set_direction(dir: Vector2) -> void:

	direction = dir.normalized()

	rotation = direction.angle() + deg_to_rad(90)


func _process(delta: float) -> void:

	global_position += direction * speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:

	queue_free()


func _on_body_entered(body):

	if body.name == "Player":

		sprite.texture = load(
			"res://Lasers/laserRed08.png"
		)

		set_process(false)

		body.take_damage()

		await get_tree().create_timer(0.2).timeout

		queue_free()
