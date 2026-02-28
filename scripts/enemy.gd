extends CharacterBody2D

const SPEED = 100.0

@onready var player_ref: CharacterBody2D = get_node("../../Beetle")
@onready var grid: Grid = get_node("../../Grid")

@export var sp_frames: SpriteFrames
@export var num_rays = 16
@export var ray_length = 80.0

var ray_directions: Array[Vector2] = []
var ass: AnimatedSprite2D
## true = hunt graves, false = hunt the player
var hunts_graves: bool = false
var _target_cell: Vector2i = Vector2i(-1, -1)
var _feeding_timer: float = 0.0

const FEED_DURATION = 2.0


func _ready() -> void:
	ass = AnimatedSprite2D.new()
	ass.sprite_frames = sp_frames
	
	# append sp frames for this enemy type to the scene
	add_child(ass)
	
	ass.sprite_frames = sp_frames
	hunts_graves = randf() < 0.5
	for i in num_rays:
		var angle = i * TAU / num_rays
		ray_directions.append(Vector2.RIGHT.rotated(angle))


func _physics_process(delta: float) -> void:
	ass.play("running")
	if not is_instance_valid(player_ref):
		return

	# Pause at grave while feeding
	if _feeding_timer > 0.0:
		velocity = Vector2.ZERO
		_feeding_timer -= delta
		if _feeding_timer <= 0.0 and _target_cell != Vector2i(-1, -1):
			grid.consume_body(_target_cell)
			_target_cell = Vector2i(-1, -1)
		return

	var target_pos = _pick_target()
	if target_pos == null:
		return

	var desired_dir = (target_pos - global_position).normalized()
	var chosen_dir = _get_avoidance_direction(desired_dir)

	var target_angle = chosen_dir.angle() + PI/2
	rotation = lerp_angle(rotation, target_angle, 0.15)

	velocity = chosen_dir * SPEED
	move_and_slide()

	# Start feeding when close enough to target grave
	if hunts_graves and _target_cell != Vector2i(-1, -1):
		if global_position.distance_to(grid.cell_center(_target_cell)) < 24.0:
			_feeding_timer = FEED_DURATION
			return

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "Beetle":
			player_ref.change_health.emit(-10)
			queue_free()
			return


## Returns the world position this enemy should move toward.
func _pick_target() -> Variant:
	if not hunts_graves:
		return player_ref.global_position

	var graves: Array[Vector2i] = grid.get_active_graves()
	if graves.is_empty():
		return player_ref.global_position

	var best_cell = graves[0]
	var best_dist := global_position.distance_squared_to(grid.cell_center(best_cell))
	for cell in graves:
		var d = global_position.distance_squared_to(grid.cell_center(cell))
		if d < best_dist:
			best_dist = d
			best_cell = cell

	_target_cell = best_cell
	return grid.cell_center(best_cell)


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
