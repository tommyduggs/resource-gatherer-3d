extends CharacterBody3D


@export var speed = 4
@export var fall_acceleration = 75
#@export var jump_impulse = 20
var target_velocity = Vector3.ZERO
@onready var animation_player = $Pivot/Barbarian/AnimationPlayer

func _ready():
	animation_player.play("Walking_B")

func _physics_process(delta):
	# variable to store input direction
	var direction = Vector3.ZERO
	
	# handle user input
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
		
	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
		
	# Add the gravity.
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Jumping.
	#if is_on_floor() and Input.is_action_just_pressed("jump"):
		#target_velocity.y = jump_impulse
		
	if velocity.length() > 0.2:
		animation_player.play("Walking_B")
	else:
		animation_player.play("Idle")
		
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Setting the basis property will affect the rotation of the node.
		$Pivot.basis = Basis.looking_at(direction, Vector3.UP, true)
		
	velocity = target_velocity
	move_and_slide()
