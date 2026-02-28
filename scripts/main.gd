extends Node2D

@onready var enemy = preload("res://scenes/enemy.tscn")
@onready var player_ref: CharacterBody2D = $Beetle
@onready var _grid: Grid = $Grid


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_grid.grave_consumed.connect(_on_body_consumed)

	player_ref.died.connect(_on_player_died)
	#var enemy_spawn_timer = get_tree().create_timer(2, true, false, true)
	var enemy_spawn_timer = Timer.new()
	enemy_spawn_timer.name = "EnemySpawnTimer"
	enemy_spawn_timer.autostart = true
	enemy_spawn_timer.one_shot = false
	enemy_spawn_timer.wait_time = 2.0
	add_child(enemy_spawn_timer)
	
	enemy_spawn_timer.timeout.connect(_spawn_enemy)
	$CardsState.card_used.connect(_on_card_used)


func _on_body_consumed(_cell: Vector2i, _consumer_name: String) -> void:
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

func _on_player_died():
	get_tree().change_scene_to_file("res://scenes/death.tscn")


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


# constants for powerups/cards
const HORNET_RANGE = 200.0
const DR_HOUSE_HEAL = 30.0
const JINDRA_SHIELD_DURATION = 5.0

func _on_card_used(card_name: String) -> void:
	if card_name == "Hornet":
		var player_pos = player_ref.global_position
		for enemy_node in $Enemies.get_children():
			if enemy_node is CharacterBody2D and player_pos.distance_to(enemy_node.global_position) <= HORNET_RANGE:
				enemy_node.queue_free()
	elif card_name == "Dr. House":
		player_ref.change_health.emit(DR_HOUSE_HEAL)
	elif card_name == "Jindřich ze Skalice":
		player_ref.shielded = true
		get_tree().create_timer(JINDRA_SHIELD_DURATION).timeout.connect(func(): player_ref.shielded = false)
