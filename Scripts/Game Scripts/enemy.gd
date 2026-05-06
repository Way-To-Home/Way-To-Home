extends CharacterBody2D

@export var move_speed := 0.0
@export var acceleration := 600.0
@export var friction := 350.0

@export var rotation_speed := 0.0

# distance enemy tries to keep from player
@export var desired_distance := 180.0
@export var distance_tolerance := 30.0

# spacing between enemies
@export var separation_distance := 90.0
@export var separation_strength := 10.0

@export var bullet_scene: PackedScene

@onready var player = $"../../Player"

@onready var shoot_timer = $ShootTimer
@onready var muzzle = $bullet_pos
@onready var area_2d = $Area2D

# rays used to check if another enemy blocks shooting
@onready var ray_center = $bullet_pos/RayCastCenter
@onready var ray_left = $bullet_pos/RayCastLeft
@onready var ray_right = $bullet_pos/RayCastRight

var can_shoot := true


func _ready():
	ray_center.add_exception(self)
	ray_left.add_exception(self)
	ray_right.add_exception(self)


func _physics_process(delta):

	if player == null:
		return

	var to_player = player.global_position - global_position
	var direction = to_player.normalized()
	var distance_to_player = to_player.length()

	var target_velocity = Vector2.ZERO

	# corner escape system
	var escape_force = Vector2.ZERO
	var is_cornered = false

	var blockers = area_2d.get_overlapping_bodies().size()

	if blockers >= 2:
		is_cornered = true

	if is_cornered:
		var random_dir = Vector2(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		).normalized()

		escape_force = random_dir * move_speed * 2.5
		target_velocity = escape_force
	else:
		if distance_to_player > (desired_distance + distance_tolerance):
			target_velocity += direction * move_speed
		elif distance_to_player < (desired_distance - distance_tolerance):
			target_velocity -= direction * move_speed

	var separation_force = Vector2.ZERO

	for body in area_2d.get_overlapping_bodies():

		if body == self:
			continue

		if body.is_in_group("enemies"):

			var enemy_distance = global_position.distance_to(body.global_position)

			if enemy_distance < separation_distance:

				var push_direction = (global_position - body.global_position).normalized()

				var push_strength = (separation_distance - enemy_distance) * separation_strength

				separation_force += push_direction * push_strength

	target_velocity += separation_force

	velocity = velocity.move_toward(target_velocity, acceleration * delta)

	if target_velocity == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	var target_rotation = direction.angle()
	target_rotation += deg_to_rad(90)

	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)

	var target_pos = to_local(player.global_position)

	ray_center.target_position = target_pos
	ray_left.target_position = target_pos
	ray_right.target_position = target_pos

	ray_center.force_raycast_update()
	ray_left.force_raycast_update()
	ray_right.force_raycast_update()

	# FIXED LINE ↓
	move_and_slide()

	handle_shooting()


func handle_shooting():

	if can_shoot == false:
		return

	var blocked := false

	var rays = [ray_center, ray_left, ray_right]

	for ray in rays:

		if ray.is_colliding():

			var collider = ray.get_collider()

			if collider != null and collider.is_in_group("enemies"):
				blocked = true

	if blocked == false:

		shoot()
		can_shoot = false
		shoot_timer.start(randf_range(0.4, 1.0))


func shoot():

	if bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)

	bullet.global_position = muzzle.global_position
	bullet.rotation = rotation

	var dir = Vector2.UP.rotated(rotation)
	bullet.set_direction(dir)


func _on_shoot_timer_timeout():
	can_shoot = true
