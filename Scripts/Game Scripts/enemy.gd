extends CharacterBody2D

@export var move_speed := 250.0

# Rotation smoothness
@export var rotation_speed := 5.0

# Distance where enemy stops near player
@export var stop_distance := 80.0

# Distance where enemy starts following again
@export var follow_distance := 120.0

@onready var player: RigidBody2D = $"../Player"

var can_follow := true


func _ready() -> void:

	# Enemy will not collide with player
	set_collision_layer_value(2, true)

	set_collision_mask_value(1, false)


func _physics_process(delta: float) -> void:

	if player == null:
		return

	var distance_to_player = global_position.distance_to(
		player.global_position
	)

	# Stop when too close
	if distance_to_player <= stop_distance:
		can_follow = false

	# Follow again when farther away
	elif distance_to_player >= follow_distance:
		can_follow = true

	if can_follow:

		var direction = (
			player.global_position - global_position
		).normalized()

		# Smooth movement
		velocity = direction * move_speed

		# Smooth rotation
		var target_rotation = (
			direction.angle() - deg_to_rad(90)
		)

		rotation = lerp_angle(
			rotation,
			target_rotation,
			rotation_speed * delta
		)

	else:

		velocity = Vector2.ZERO

	move_and_slide()
