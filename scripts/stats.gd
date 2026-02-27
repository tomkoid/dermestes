extends VBoxContainer

@onready var player_ref = $"../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_ref.health_changed.connect(update_hp)

func update_hp(value: int, maximum: int):
	$HP.text = "HP: "+ str(value)

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
