extends Node2D

enum CardType {
	ATTACK,
	DEFENSE,
	INTELLECT
}

var CARDS = [
	{
		"name": "Hornet",
		"type": CardType.ATTACK,
		"description": "SHAW! EDIREEE! HENGALEEE!",
		"card_image_path": "res://assets/karty/hornet.png"
	},
	{
		"name": "Dr. House",
		"type": CardType.INTELLECT,
		"description": "Není to Lupus!!",
		"card_image_path": "res://assets/karty/house.png"
	},
	{
		"name": "Jindřich ze Skalice",
		"type": CardType.DEFENSE,
		"description": "asdfjasdfkjfjasd",
		"card_image_path": "res://assets/karty/jindra.png"
	},
]

var cards_applied = []

@onready var grid_ref = $"../Grid"

signal card_add(index: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid_ref.grave_consumed.connect(_handle_grave_consumed)
	card_add.connect(_handle_card_add)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func get_cards():
	return cards_applied

func _handle_grave_consumed(_cell: Vector2, consumer_name: String):
	if consumer_name != "Beetle":
		return
	
	var rand_index = randi_range(0, len(CARDS)-1)
	card_add.emit(rand_index)

func _handle_card_add(index: int):
	cards_applied.push_back(CARDS[index])
