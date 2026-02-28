extends CharacterBody2D

const SPEED = 100.0

@onready var player_ref: CharacterBody2D = get_node("../../Beetle")

@export var sp_frames: SpriteFrames
@export var num_rays = 16
@export var ray_length = 80.0

var ray_directions: Array[Vector2] = []
var ass: AnimatedSprite2D


func _ready() -> void:
	ass = AnimatedSprite2D.new()
	ass.sprite_frames = sp_frames
	
	# append sp frames for this enemy type to the scene
	add_child(ass)
	
	ass.sprite_frames = sp_frames
	for i in num_rays:
		var angle = i * TAU / num_rays
		ray_directions.append(Vector2.RIGHT.rotated(angle))


func _physics_process(delta: float) -> void:
	ass.play("running")
	if not is_instance_valid(player_ref):
		return

	var desired_dir = (player_ref.global_position - global_position).normalized()
	var chosen_dir = _get_avoidance_direction(desired_dir)
	
	var target_angle = chosen_dir.angle() + PI/2
	rotation = lerp_angle(rotation, target_angle, 0.15)
	
	velocity = chosen_dir * SPEED
	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "Beetle":
			player_ref.change_health.emit(-10)
			queue_free()
			return


func _get_avoidance_direction(desired_dir: Vector2) -> Vector2:
	var space_state = get_world_2d().direct_space_state
	var interest: Array[float] = []
	var danger: Array[float] = []

	for dir in ray_directions:
		interest.append(maxf(0.0, dir.dot(desired_dir)))
		danger.append(0.0)

	for i in num_rays:
		var query = PhysicsRayQueryParameters2D.create(
			global_position,
			global_position + ray_directions[i] * ray_length,
			0xFFFFFFFF,
			[get_rid()]
		)
		var result = space_state.intersect_ray(query)
		if result and result.collider != player_ref:
			var dist = global_position.distance_to(result.position)
			danger[i] = 1.0 - (dist / ray_length)

	var best_dir = desired_dir
	var best_weight = -INF
	for i in num_rays:
		var weight = interest[i] - danger[i]
		if weight > best_weight:
			best_weight = weight
			best_dir = ray_directions[i]

	return best_dir.normalized()
