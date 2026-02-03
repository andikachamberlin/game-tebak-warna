extends Control

@onready var back_button = $CenterContainer/VBoxContainer/BackButton
@onready var volume_slider = $CenterContainer/VBoxContainer/VolumeHBox/VolumeSlider

func _ready():
	# Initialize slider value from current bus volume
	var bus_index = AudioServer.get_bus_index("Master")
	var volume_db = AudioServer.get_bus_volume_db(bus_index)
	# Convert db to linear (0-1) for slider, assuming 0db is max or handling range
	# db_to_linear is better
	volume_slider.value = db_to_linear(volume_db)

func _on_volume_slider_value_changed(value):
	var bus_index = AudioServer.get_bus_index("Master")
	# Linear to db
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	# Mute if 0
	AudioServer.set_bus_mute(bus_index, value == 0)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_reset_score_pressed():
	GameManager.high_score = 0
	GameManager.save_game()
	# Optional: Show confirmation or feedback
