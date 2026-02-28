extends VBoxContainer

@onready var player_ref = $"../../../Beetle"
@onready var cards_state_ref = $"../../../CardsState"

var time_elapsed = 0.0
var stopwatch_stopped = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stopwatch_stopped = false
	player_ref.health_changed.connect(update_hp)
	player_ref.died.connect(update_died)
	cards_state_ref.card_add.connect(update_cards)

func _process(delta: float) -> void:
	if !stopwatch_stopped:
		time_elapsed += delta
		update_time_elapsed()

func update_hp(value: float, maximum: int):
	$HP.value = ceil(value)

func update_cards(_index: int):
	var cg_children = $CardsGrid.get_children()
	for child in cg_children:
		$CardsGrid.remove_child(child)
	
	for card in cards_state_ref.cards_applied:
		print(card)
		
		var card_image_path = card.card_image_path
		var sprite = Sprite2D.new()
		var img_texture = load(card_image_path)
		sprite.texture = img_texture
		sprite.scale = Vector2(2,2)
		
		$CardsGrid.add_child(sprite)

func update_time_elapsed():
	$Time.text = "TIME " + str(time_elapsed).pad_decimals(2) + "s"

func update_died():
	stopwatch_stopped = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
