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

var laser_scene = preload("res://Scenes/Level Scenes/laser.tscn")

var can_shoot := false

# Different movement styles
enum MovementMode {
	SLIPPERY, # Feels floaty, keeps momentum
	SOLID     # Feels tight and responsive
}

@export var movement_mode := MovementMode.SLIPPERY

# We store input here so it can be safely used in the physics step
var _input_vector := Vector2.ZERO


func _ready() -> void:
	# Turn off gravity so the player doesn't drift
	gravity_scale = 0

	# Make sure we start completely still
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

	set_movement_mode(movement_mode)

	# Enable/disable camera if it exists
	if camera:
		camera.enabled = enable_camera


func set_movement_mode(mode: MovementMode) -> void:
	movement_mode = mode

	match movement_mode:
		MovementMode.SLIPPERY:
			# Low damping = more sliding
			linear_damp = 0.2
			angular_damp = 2.0

		MovementMode.SOLID:
			# High damping = stops quickly
			linear_damp = 6.0
			angular_damp = 10.0


func _physics_process(_delta: float) -> void:

	# Handle shooting input
	if can_shoot:
		shoot()

	var input_vector := Vector2.ZERO

	# Read movement input
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1

	# Normalize so diagonal movement isn't faster
	_input_vector = input_vector.normalized()

	# Slippery movement uses forces (this is the correct way for RigidBody)
	if movement_mode == MovementMode.SLIPPERY:
		if _input_vector != Vector2.ZERO:
			var move_force = _input_vector * player_force
			apply_force(move_force)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Always face the mouse
	var target_pos = get_global_mouse_position()
	var angle = (target_pos - state.transform.origin).angle()
	state.transform = Transform2D(angle + deg_to_rad(90), state.transform.origin)

	# Solid movement directly sets velocity here (safe place to do it)
	if movement_mode == MovementMode.SOLID:
		state.linear_velocity = _input_vector * 350


# Shooting logic
func shoot() -> void:

	# Safety checks
	if not muzzle:
		return
	if not shoot_cool_down:
		return

	# Fire only if button is pressed and cooldown is ready
	if Input.is_action_just_pressed("shoot") and shoot_cool_down.is_stopped():
		shoot_laser()
		shoot_cool_down.start()


func shoot_laser() -> void:
	var l = laser_scene.instantiate()

	# Spawn laser at the muzzle position and rotation
	l.global_position = muzzle.global_position
	l.rotation = rotation

	emit_signal("laser_shot", l)
