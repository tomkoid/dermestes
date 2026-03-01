extends VBoxContainer

@onready var player_ref = $"../../../Beetle"
@onready var cards_state_ref = $"../../../CardsState"

var time_elapsed = 0.0
var stopwatch_stopped = false

var graves_eaten = 0

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
		card_panel.mouse_filter = Control.MOUSE_FILTER_STOP

		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.2, 0.22, 0)
		style.corner_radius_top_left = 6
		style.corner_radius_top_right = 6
		style.corner_radius_bottom_left = 6
		style.corner_radius_bottom_right = 6
		style.content_margin_left = 8
		style.content_margin_right = 8
		style.content_margin_top = 8
		style.content_margin_bottom = 8
		card_panel.add_theme_stylebox_override("panel", style)

		card_panel.mouse_entered.connect(func(): style.bg_color = Color(0.35, 0.35, 0.38, 0.9))
		card_panel.mouse_exited.connect(func(): style.bg_color = Color(0.2, 0.2, 0.22, 0))

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
		
		var actual_desc = Label.new()
		actual_desc.text = card.actual_desc
		actual_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		actual_desc.autowrap_mode = TextServer.AUTOWRAP_WORD
		actual_desc.add_theme_font_size_override("font_size", 11)
		actual_desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		vbox.add_child(actual_desc)

		var card_name = card.name
		card_panel.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				cards_state_ref.remove_card(card_name)
		)
		card_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		$CardsView.add_child(card_panel)

func _on_card_used(card_name: String):
	create_toast("[font_size=36]You used the [b][color=yellow]%s[/color][/b] card![/font_size]" % card_name)
	update_cards(-1)

func update_time_elapsed():
	$Time.text = "Time " + str(time_elapsed).pad_decimals(2) + "s"



func update_died():
	stopwatch_stopped = true
	GameState.graves_eaten = graves_eaten
	GameState.time_elapsed = time_elapsed
	
func create_toast(content: String):
	var label = RichTextLabel.new()
	label.text = content
	label.fit_content = true
	label.bbcode_enabled = true
	label.position = Vector2(300, 500)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(600,400)
	label.modulate.a = 0.0
	
	label.scroll_active = false
		
	var tween = get_tree().create_tween()
	
	# fade in
	tween.tween_property(label, "modulate:a", 1.0, 0.3)

	# Create a parallel sub-tween
	var parallel = tween.parallel()
	parallel.tween_property(label, "position:y", label.position.y - 40, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
	parallel.tween_property(label, "modulate:a", 0.0, 1.5)
	
	tween.tween_callback(label.queue_free)
	
	$"../../../UI".add_child.call_deferred(label)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_grid_grave_consumed(cell: Vector2i, consumer_name: String) -> void:
	if consumer_name == "Beetle":
		graves_eaten += 1
		$Graves.text = "Graves: " + str(graves_eaten)
