extends Node2D

var card_initializer = Card.new()

var CARDS: Array[Card] = [
	card_initializer.init("Hornet", "SHAW! EDIREEE! HENGALEEE!", Card.CardType.ATTACK, "res://assets/karty/hornet.png"),
	card_initializer.init("Dr. House", "Není to Lupus!!", Card.CardType.INTELLECT, "res://assets/karty/house.png"),
	card_initializer.init("Jindřich ze Skalice", "I feel quite hungry.", Card.CardType.DEFENSE, "res://assets/karty/jindra.png"),
]

var cards_applied = []
const MAX_CARDS = 2

@onready var grid_ref = $"../Grid"

signal card_add(index: int)
signal card_used(card_name: String)

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

func remove_card(card_name: String) -> void:
	for i in cards_applied.size():
		if cards_applied[i].name == card_name:
			cards_applied.remove_at(i)
			card_used.emit(card_name)
			return

func _handle_card_add(index: int):
	if cards_applied.size() >= MAX_CARDS:
		return
	cards_applied.push_back(CARDS[index])
