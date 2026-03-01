extends Control


func _ready() -> void:
	pass


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn") 


func _on_settings_button_pressed() -> void:
	$SettingsPopup.visible = true


func _on_exit_button_pressed() -> void:
	get_tree().quit()
