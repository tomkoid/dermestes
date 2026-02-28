extends VBoxContainer

@onready var player_ref = $"../../../Beetle"

var time_elapsed = 0.0
var stopwatch_stopped = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stopwatch_stopped = false
	player_ref.health_changed.connect(update_hp)
	player_ref.died.connect(update_died)

func _process(delta: float) -> void:
	if !stopwatch_stopped:
		time_elapsed += delta
		update_time_elapsed()

func update_hp(value: float, maximum: int):
	$HP.value = ceil(value)

func update_time_elapsed():
	$Time.text = "TIME " + str(time_elapsed).pad_decimals(2) + "s"

func update_died():
	stopwatch_stopped = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
