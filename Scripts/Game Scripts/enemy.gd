extends CharacterBody2D

@export var move_speed := 150.0
@export var rotation_speed := 20.0
@export var stop_distance := 80.0
@export var follow_distance := 120.0
@export var bullet_scene: PackedScene

@onready var player: RigidBody2D = $"../Player"
@onready var shoot_timer: Timer = $ShootTimer
@onready var muzzle: Marker2D = $bullet_pos

var can_follow := true
var can_shoot := true


func _physics_process(delta: float) -> void:
	if player == null:
		return

	var distance_to_player = global_position.distance_to(player.global_position)

	# follow logic
	if distance_to_player <= stop_distance:
		can_follow = false
	elif distance_to_player >= follow_distance:
		can_follow = true

	var direction = (player.global_position - global_position).normalized()

	# movement
	if can_follow:
		velocity = direction * move_speed
	else:
		velocity = Vector2.ZERO

	# rotation always tracks player
	var target_rotation = direction.angle() - deg_to_rad(90)
	target_rotation += PI
	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)

	move_and_slide()

	# shooting
	if can_shoot:
		shoot()
		can_shoot = false
		shoot_timer.start(randf_range(0.2, 1.0))


func shoot() -> void:
	if bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)

	# spawn position
	bullet.global_position = muzzle.global_position

	# align bullet rotation with enemy rotation
	bullet.rotation = rotation

	# direction vector based on rotation
	var dir = Vector2.UP.rotated(rotation).normalized()
	bullet.set_direction(dir)

	# optional: give bullet initial velocity if it supports it
	if bullet.has_method("set_velocity"):
		bullet.set_velocity(dir * 400) # adjust speed as needed


func _on_shoot_timer_timeout() -> void:
	can_shoot = true
	shoot_timer.stop()
