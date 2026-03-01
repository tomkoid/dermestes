extends Node

var graves_eaten: int = 0
var time_elapsed: float = 0.0

var _player: AudioStreamPlayer


func _ready() -> void:
	_apply_saved_audio_settings()
	_player = AudioStreamPlayer.new()
	_player.bus = "SFX"
	_player.stream = preload("res://assets/sounds/button.mp3")
	add_child(_player)
	get_tree().node_added.connect(_on_node_added)


func _apply_saved_audio_settings() -> void:
	var cfg := ConfigFile.new()
	var path := "user://settings.cfg"
	if cfg.load(path) != OK:
		return
	for entry in [["Master", "master"], ["SFX", "sfx"], ["Music", "music"]]:
		var idx := AudioServer.get_bus_index(entry[0])
		if idx == -1:
			continue
		var vol: float = cfg.get_value("audio", entry[1], 1.0)
		AudioServer.set_bus_volume_db(idx, linear_to_db(vol))
		AudioServer.set_bus_mute(idx, vol < 0.01)


func _on_node_added(node: Node) -> void:
	if node is Button:
		node.pressed.connect(_play_click)


func _play_click() -> void:
	if _player.stream:
		_player.play()
