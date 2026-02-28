class_name Card

var name: String
var desc: String
var actual_desc: String
var type: CardType
var image_texture_path: String


enum CardType {
	ATTACK,
	DEFENSE,
	INTELLECT
}

func init(name: String, actual_desc: String, desc: String, type: CardType, img_texture_path: String) -> Card:
	var card: Card = Card.new()
	card.name = name
	card.desc = desc
	card.actual_desc = actual_desc
	card.type = type
	card.image_texture_path = img_texture_path
	
	return card
