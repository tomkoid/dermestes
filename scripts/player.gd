extends CharacterBody2D

## Path to the Grid node (sibling by default).
@export var grid_path: NodePath = NodePath("../Grid")

@export var speed: float = 200.0
@export var max_health: float = 100.0
## HP lost per second (starvation).
@export var health_drain_rate: float = 2.0
## HP gained per second while actively eating.
@export var heal_rate: float = 20.0
## Fraction of body content consumed per second while eating.
@export var body_drain_rate: float = 0.25
## World-pixel radius within which the player can eat from a grave.
@export var feed_range: float = 130.0

var health: float

var _grid: Grid = null
var _is_feeding: bool = false
var _nearby_grave: Vector2i = Vector2i(-1, -1)

@onready var _body_visual: Polygon2D = $Body
@onready var _feed_indicator: Polygon2D = $FeedIndicator
@onready var _health_label: Label = $HealthLabel
@onready var _ass: AnimatedSprite2D = $AnimatedSprite2D

@onready var _cards_state = $"../CardsState"

signal health_changed(value: float, maximum: float)
signal change_health(value: float)
signal died
signal body_consumed(cell: Vector2i)


func _ready() -> void:
	change_health.connect(_handle_change_health)
	
	health = max_health
	_grid = get_node(grid_path)


func _process(delta: float) -> void:
	_nearby_grave = _nearest_grave_in_range()
	_tick_feeding(delta)
	_tick_health(delta)
	#_update_visuals()


func _physics_process(delta: float) -> void:
	var dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	if dir != Vector2.ZERO:
		_ass.play("running")
		var target_angle = dir.angle() + PI/2
		rotation = lerp_angle(rotation, target_angle, 0.15)
		
		if !_is_feeding:
			velocity = dir.normalized() * speed
		else:
			velocity = Vector2.ZERO
	else:
		_ass.play("idle")
		velocity = Vector2.ZERO

	move_and_slide()
	_clamp_to_grid()


# ---------------------------------------------------------------------------
# Ticks
# ---------------------------------------------------------------------------

func _tick_feeding(delta: float) -> void:
	_is_feeding = false
	if not Input.is_action_pressed("ui_accept"):
		return
	if _nearby_grave == Vector2i(-1, -1):
		return
	var drained := _grid.eat_body(_nearby_grave, body_drain_rate * delta, name)
	if drained > 0.0:
		_is_feeding = true
		health = minf(health + heal_rate * delta, max_health)
		if not _grid.has_body(_nearby_grave):
			body_consumed.emit(_nearby_grave)


func _tick_health(delta: float) -> void:
	if velocity != Vector2.ZERO:
		health = clampf(health - health_drain_rate * delta, 0.0, max_health)
	health_changed.emit(health, max_health)
	if health <= 0.0:
		set_process(false)
		set_physics_process(false)
		died.emit()


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _clamp_to_grid() -> void:
	var bounds: Rect2 = _grid.get_world_bounds()
	global_position.x = clampf(global_position.x, bounds.position.x, bounds.end.x)
	global_position.y = clampf(global_position.y, bounds.position.y, bounds.end.y)


## Returns the nearest grave cell within feed_range, or Vector2i(-1,-1) if none.
func _nearest_grave_in_range() -> Vector2i:
	var cell := _grid.world_to_cell(global_position)
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			var c := cell + Vector2i(dx, dy)
			if _grid.has_body(c):
				if global_position.distance_to(_grid.cell_center(c)) <= feed_range:
					return c
	return Vector2i(-1, -1)

var shielded: bool = false

func _handle_change_health(value: float):
	if value < 0 and shielded:
		return
	health = health + value

#func _update_visuals() -> void:
	## Body color: green (healthy) → red (starving)
	#var hp_ratio := health / max_health
	#_body_visual.color = Color(0.7, 0.15, 0.1).lerp(Color(0.35, 0.65, 0.25), hp_ratio)
#
	## Yellow glow while eating
	#_feed_indicator.visible = _is_feeding
#
	## Label
	#var hint := ""
	#if _is_feeding:
		#hint = " [eating]"
	#elif _nearby_grave != Vector2i(-1, -1):
		#hint = " [Space]"
	#_health_label.text = "HP %d%s" % [roundi(health), hint]
