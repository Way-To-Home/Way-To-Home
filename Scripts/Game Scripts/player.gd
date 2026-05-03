# =========================
# PLAYER SCRIPT
# =========================

extends RigidBody2D

signal laser_shot(laser)

@export var player_force := 1500.0

@export var enable_camera := true

@onready var camera: Camera2D = get_node_or_null("Camera2D")

@onready var muzzle: Node2D = get_node_or_null("Muzzle")

@onready var shoot_cool_down: Timer = get_node_or_null("ShootCoolDown")

var laser_scene = preload(
	"res://Scenes/Level Scenes/laser.tscn"
)

var can_shoot := false

# Movement types
enum MovementMode {
	SLIPPERY,
	SOLID
}

@export var movement_mode := MovementMode.SLIPPERY


func _ready() -> void:

	# Prevent unwanted movement
	gravity_scale = 0

	linear_velocity = Vector2.ZERO

	angular_velocity = 0.0

	set_movement_mode(movement_mode)

	# Camera control
	if camera:
		camera.enabled = enable_camera


func set_movement_mode(mode: MovementMode) -> void:

	movement_mode = mode

	match movement_mode:

		MovementMode.SLIPPERY:

			linear_damp = 0.2

			angular_damp = 2.0

		MovementMode.SOLID:

			linear_damp = 6.0

			angular_damp = 10.0


func _physics_process(_delta: float) -> void:

	# Shooting
	if can_shoot:
		shoot()

	# Rotate to mouse
	look_at(get_global_mouse_position())

	rotation += deg_to_rad(90)

	var input_vector := Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		input_vector.x += 1

	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1

	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1

	if Input.is_action_pressed("move_down"):
		input_vector.y += 1

	input_vector = input_vector.normalized()

	match movement_mode:

		# Smooth slippery movement
		MovementMode.SLIPPERY:

			if input_vector != Vector2.ZERO:

				var move_force = input_vector * player_force

				apply_force(move_force)

		# Tight movement
		MovementMode.SOLID:

			linear_velocity = input_vector * 350


# Shooting
func shoot() -> void:

	if not muzzle:
		return

	if not shoot_cool_down:
		return

	if Input.is_action_just_pressed("shoot") and shoot_cool_down.is_stopped():

		shoot_laser()

		shoot_cool_down.start()


func shoot_laser() -> void:

	var l = laser_scene.instantiate()

	l.global_position = muzzle.global_position

	l.rotation = rotation

	emit_signal("laser_shot", l)
