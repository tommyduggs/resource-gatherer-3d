extends CharacterBody3D


@export var speed = 4
@export var fall_acceleration = 75
@export var camera : Camera3D
@onready var animation_player = $Pivot/Barbarian/AnimationPlayer
var walking = false
var target_position = Vector3.ZERO
var target_velocity = Vector3.ZERO
var pathfinding_threshold = 0.1
const TREE_PATHFINDING_THRESHOLD = 1.5
const GROUND_PATHFINDING_THRESHOLD = 0.1

func _ready():
	animation_player.play("Walking_B")
	
# TODO: Move all this click logic to a separate script
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
	
	ray_query.collision_mask = 0b0011
	
	ray_query.from = from
	ray_query.to = to
	
	var result = space.intersect_ray(ray_query)
	
	if not result.is_empty():
		var collider : StaticBody3D = result.collider
		
		# Clicked on the ground
		if collider.collision_layer == 1:
			pathfinding_threshold = GROUND_PATHFINDING_THRESHOLD
			# Set the target position
			target_position = result.position
			# Set the flag so that the player starts walking
			walking = true
			$Pivot.basis = Basis.looking_at(target_position - position, Vector3.UP, true)
		# Clicked on a resource
		elif collider.collision_layer == 2:
			pathfinding_threshold = TREE_PATHFINDING_THRESHOLD
			target_position = collider.position #Vector3(collider.position.x, collider.position.y, collider.position.z)
			walking = true
			$Pivot.basis = Basis.looking_at(target_position - position, Vector3.UP, true)
	
func reached_destination():
	return abs(target_position.x - position.x) < pathfinding_threshold and abs(target_position.z - position.z) < pathfinding_threshold

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
