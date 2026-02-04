extends Control

@onready var back_button = $CenterContainer/VBoxContainer/BackButton
@onready var music_slider = $CenterContainer/VBoxContainer/MusicSlider
@onready var sfx_slider = $CenterContainer/VBoxContainer/SFXSlider

func _ready():
	# Initialize music slider
	var music_bus = AudioServer.get_bus_index("Music")
	# If bus doesn't exist (fallback), might be -1. Safe to check?
	# Assuming AudioManager setup buses in project settings or script.
	if music_bus != -1:
		music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	else:
		# Fallback to master if Music bus not found
		music_bus = AudioServer.get_bus_index("Master")
		music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))

	# Initialize SFX slider
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus != -1:
		sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))
	else:
		sfx_bus = AudioServer.get_bus_index("Master")
		sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))

func _on_music_slider_value_changed(value):
	var bus_index = AudioServer.get_bus_index("Music")
	if bus_index == -1: bus_index = AudioServer.get_bus_index("Master")
	
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value == 0)

func _on_sfx_slider_value_changed(value):
	var bus_index = AudioServer.get_bus_index("SFX")
	if bus_index == -1: bus_index = AudioServer.get_bus_index("Master")
	
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value == 0)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_reset_score_pressed():
	GameManager.high_score = 0
	GameManager.save_game()
	# Optional: Show confirmation or feedback
