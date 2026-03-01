extends ColorRect

func _ready() -> void:
	$VBox/ResumeButton.pressed.connect(_toggle_pause)
	$VBox/MenuButton2.pressed.connect(_go_to_menu)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()
		get_viewport().set_input_as_handled()


func _toggle_pause() -> void:
	var paused = !get_tree().paused
	get_tree().paused = paused
	visible = paused


func _go_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
