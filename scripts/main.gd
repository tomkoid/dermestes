extends Node2D

@onready var enemy = preload("res://scenes/enemy.tscn")
@onready var player_ref: CharacterBody2D = $Beetle
@onready var _grid: Grid = $Grid

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_grid.grave_consumed.connect(_on_body_consumed)

	player_ref.body_consumed.connect(_on_body_consumed)

	#var enemy_spawn_timer = get_tree().create_timer(2, true, false, true)
	var enemy_spawn_timer = Timer.new()
	enemy_spawn_timer.name = "EnemySpawnTimer"
	enemy_spawn_timer.autostart = true
	enemy_spawn_timer.one_shot = false
	enemy_spawn_timer.wait_time = 2.0
	add_child(enemy_spawn_timer)
	
	enemy_spawn_timer.timeout.connect(_spawn_enemy)


func _on_body_consumed(_cell: Vector2i) -> void:
	_grid.spawn_random_grave()

func _spawn_enemy():
	var e = enemy.instantiate()
	
	var enemy_type_index = randi_range(1,2)
	e.sp_frames = load("res://animations/enemy%d.tres" % enemy_type_index)
	var bounds := _grid.get_world_bounds()
	var offset := float(_grid.tile_size)
	var corners := [
		bounds.position + Vector2(-offset, -offset),
		bounds.position + Vector2(bounds.size.x + offset, -offset),
		bounds.position + Vector2(-offset, bounds.size.y + offset),
		bounds.end + Vector2(offset, offset),
	]
	e.global_position = corners[randi() % corners.size()]
	$Enemies.add_child(e)
