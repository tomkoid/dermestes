extends PanelContainer

const SAVE_PATH = "user://settings.cfg"

@onready var _master_slider: HSlider = $VBox/MasterRow/MasterSlider
@onready var _sfx_slider: HSlider = $VBox/SFXRow/SFXSlider
@onready var _music_slider: HSlider = $VBox/MusicRow/MusicSlider

func _ready() -> void:
	_load_settings()
	_master_slider.value_changed.connect(_on_master_changed)
	_sfx_slider.value_changed.connect(_on_sfx_changed)
	_music_slider.value_changed.connect(_on_music_changed)
	$VBox/CloseButton.pressed.connect(_close)


func _on_master_changed(value: float) -> void:
	_set_bus_volume("Master", value)
	_save_settings()


func _on_sfx_changed(value: float) -> void:
	_set_bus_volume("SFX", value)
	_save_settings()


func _on_music_changed(value: float) -> void:
	_set_bus_volume("Music", value)
	_save_settings()


func _set_bus_volume(bus_name: String, value: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	AudioServer.set_bus_volume_db(idx, linear_to_db(value))
	AudioServer.set_bus_mute(idx, value < 0.01)


func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", _master_slider.value)
	cfg.set_value("audio", "sfx", _sfx_slider.value)
	cfg.set_value("audio", "music", _music_slider.value)
	cfg.save(SAVE_PATH)


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	_master_slider.value = cfg.get_value("audio", "master", 1.0)
	_sfx_slider.value = cfg.get_value("audio", "sfx", 1.0)
	_music_slider.value = cfg.get_value("audio", "music", 1.0)
	_on_master_changed(_master_slider.value)
	_on_sfx_changed(_sfx_slider.value)
	_on_music_changed(_music_slider.value)


func _close() -> void:
	visible = false


static func apply_saved_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	for entry in [["Master", "master"], ["SFX", "sfx"], ["Music", "music"]]:
		var idx := AudioServer.get_bus_index(entry[0])
		if idx == -1:
			continue
		var vol: float = cfg.get_value("audio", entry[1], 1.0)
		AudioServer.set_bus_volume_db(idx, linear_to_db(vol))
		AudioServer.set_bus_mute(idx, vol < 0.01)
