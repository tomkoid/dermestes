extends CharacterBody2D


const SPEED = 100.0

@onready var ass = $AnimatedSprite2D
@onready var player_ref: CharacterBody2D = get_node("../../Beetle")

@export var sp_frames: SpriteFrames


func _ready() -> void:
	ass.sprite_frames = sp_frames


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player_ref):
		return

	var dir = (player_ref.global_position - global_position).normalized()
	look_at(player_ref.global_position)
	velocity = dir * SPEED
	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "Beetle":
			player_ref.change_health.emit(-10)
			queue_free()
			return
