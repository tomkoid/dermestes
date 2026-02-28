extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -400.0

@onready var ass = $AnimatedSprite2D
@onready var player_ref: CharacterBody2D = get_node("../../Beetle")

@export var sp_frames: SpriteFrames


func _ready() -> void:
	ass.sprite_frames = sp_frames


func _physics_process(delta: float) -> void:
	# calc dir to player
	var dir = (player_ref.global_position - global_position).normalized()
	#velocity = dir * SPEED
	
	look_at(player_ref.global_position)

	# on collision
	var collision = move_and_collide(dir)
	if collision and collision.get_collider().name == "Beetle":
		player_ref.change_health.emit(-10)
		queue_free()
