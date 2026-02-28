extends Area2D

@export var sprite_frames: SpriteFrames
@onready var anim_sprite2d = $AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_sprite2d.sprite_frames = sprite_frames # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
