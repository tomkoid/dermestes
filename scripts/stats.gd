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
	cards_state_ref.card_used.connect(_on_card_used)

func _process(delta: float) -> void:
	if !stopwatch_stopped:
		time_elapsed += delta
		update_time_elapsed()

func update_hp(value: float, maximum: int):
	$HP.value = ceil(value)

func update_cards(_index: int):
	var cg_children = $CardsView.get_children()
	for child in cg_children:
		if child.name != "Sprite2D":
			$CardsView.remove_child(child)
			child.queue_free()
	
	for card in cards_state_ref.cards_applied:
		var card_panel = PanelContainer.new()
		card_panel.custom_minimum_size = Vector2(120, 0)

		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.2, 0.22, 0.9)
		style.corner_radius_top_left = 6
		style.corner_radius_top_right = 6
		style.corner_radius_bottom_left = 6
		style.corner_radius_bottom_right = 6
		style.content_margin_left = 8
		style.content_margin_right = 8
		style.content_margin_top = 8
		style.content_margin_bottom = 8
		card_panel.add_theme_stylebox_override("panel", style)

		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
		vbox.add_theme_constant_override("separation", 4)
		card_panel.add_child(vbox)

		var title = Label.new()
		title.text = card.name
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.add_theme_font_size_override("font_size", 14)
		vbox.add_child(title)

		var img_texture = load(card.image_texture_path)
		if img_texture:
			var tex_rect = TextureRect.new()
			tex_rect.texture = img_texture
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex_rect.custom_minimum_size = Vector2(96, 96)
			vbox.add_child(tex_rect)

		var desc = Label.new()
		desc.text = card.desc
		desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD
		desc.add_theme_font_size_override("font_size", 11)
		desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		vbox.add_child(desc)

		var card_name = card.name
		card_panel.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				cards_state_ref.remove_card(card_name)
		)
		card_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		$CardsView.add_child(card_panel)

func _on_card_used(_card_name: String):
	update_cards(-1)

func update_time_elapsed():
	$Time.text = "TIME " + str(time_elapsed).pad_decimals(2) + "s"

func update_died():
	stopwatch_stopped = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
