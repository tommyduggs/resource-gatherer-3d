extends CharacterBody3D


@export var speed = 4
@export var fall_acceleration = 75
@export var camera : Camera3D
#@export var jump_impulse = 20
var target_velocity = Vector3.ZERO
@onready var animation_player = $Pivot/Barbarian/AnimationPlayer
var walking = false
var target_position = Vector3.ZERO


func _ready():
	animation_player.play("Walking_B")
	
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			get_world_position(event.position)
			
func get_world_position(mouse_position):
	var ray_length = 200; #???
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	
	ray_query.from = from
	ray_query.to = to
	
	var result = space.intersect_ray(ray_query)
	
	# Set the target position
	target_position = result.position
	# Set the flag so that the player starts walking
	walking = true
	$Pivot.basis = Basis.looking_at(target_position - position, Vector3.UP, true)
	
func reached_destination():
	return abs(target_position.x - position.x) < 0.1 and abs(target_position.z - position.z) < 0.1

func _physics_process(delta):
	if walking and not reached_destination():
		velocity = (target_position - position).normalized() * speed
		#$Pivot.basis = Basis.looking_at(velocity, Vector3.UP, true)
	if walking and reached_destination():
		velocity = Vector3.ZERO
		walking = false
		
	if velocity.length() > 0.2:
		animation_player.play("Walking_B")
	else:
		animation_player.play("Idle")
		
	move_and_slide()
