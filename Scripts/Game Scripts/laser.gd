extends Area2D

@export var speed := 700

func _ready() -> void:
	scale = Vector2.ZERO

	var tween = create_tween()

	tween.tween_property(
		self,
		"scale",
		Vector2.ONE,
		0.15
	)

	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	global_position += Vector2.UP.rotated(rotation) * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area is Asteroid:
		area.call_deferred("explode")
		queue_free()


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
