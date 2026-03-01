extends Node

var graves_eaten: int = 0
var time_elapsed: float = 0.0

var _player: AudioStreamPlayer


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	_player.stream = preload("res://assets/sounds/button.mp3")
	add_child(_player)
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node) -> void:
	if node is Button:
		node.pressed.connect(_play_click)


func _play_click() -> void:
	if _player.stream:
		_player.play()
