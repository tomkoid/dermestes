extends CanvasLayer

@onready var enemy = preload("res://scenes/enemy.tscn")
@onready var player_ref: CharacterBody2D = $"../Beetle"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var enemy_spawn_timer = get_tree().create_timer(2, true, false, true)
	var enemy_spawn_timer = Timer.new()
	enemy_spawn_timer.name = "EnemySpawnTimer"
	enemy_spawn_timer.autostart = true
	enemy_spawn_timer.one_shot = false
	enemy_spawn_timer.wait_time = 2.0
	add_child(enemy_spawn_timer)
	
	enemy_spawn_timer.timeout.connect(_spawn_enemy)

func _spawn_enemy():
	var e = enemy.instantiate()
	e.sp_frames = load("res://animations/enemy1.tres")
	$Enemies.add_child(e)
