@tool
extends Control

@onready var start_button = $StartButton
@onready var stroop_button = $StroopButton
@onready var object_button = $ObjectButton
@onready var quit_button = $QuitButton
@onready var high_score_label = $HighScoreLabel
@onready var platformer_button = $PlayPlatformerButton
@onready var settings_button = $SettingsButton

func _ready():
	# Update High Score Display
	high_score_label.text = "Rekor Tertinggi: " + str(GameManager.high_score)
	
	setup_buttons()

func setup_buttons():
	start_button.pivot_offset = start_button.size / 2
	stroop_button.pivot_offset = stroop_button.size / 2
	object_button.pivot_offset = object_button.size / 2
	platformer_button.pivot_offset = platformer_button.size / 2
	settings_button.pivot_offset = settings_button.size / 2
	quit_button.pivot_offset = quit_button.size / 2
	
	start_button.scale = Vector2.ZERO
	stroop_button.scale = Vector2.ZERO
	object_button.scale = Vector2.ZERO
	platformer_button.scale = Vector2.ZERO
	settings_button.scale = Vector2.ZERO
	quit_button.scale = Vector2.ZERO
	
	var tween = create_tween()
	tween.tween_interval(0.2)
	tween.tween_property(start_button, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.1)
	tween.tween_property(stroop_button, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.1)
	tween.tween_property(object_button, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.1)
	tween.tween_property(platformer_button, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.1)
	tween.tween_property(settings_button, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.1)
	tween.tween_property(quit_button, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_start_button_pressed():
	GameManager.current_mode = "classic"
	animate_button_press(start_button)

func _on_stroop_button_pressed():
	GameManager.current_mode = "stroop"
	animate_button_press(stroop_button)

func _on_object_button_pressed():
	GameManager.current_mode = "object"
	animate_button_press(object_button)

func _on_play_platformer_button_pressed():
	GameManager.current_mode = "platformer"
	animate_button_press(platformer_button)

func _on_settings_button_pressed():
	GameManager.current_mode = "settings"
	animate_button_press(settings_button)

func animate_button_press(btn):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(btn, "scale", Vector2(1, 1), 0.1)
	tween.tween_callback(change_scene)

func change_scene():
	if GameManager.current_mode == "platformer":
		get_tree().change_scene_to_file("res://scenes/platformer_game.tscn")
	elif GameManager.current_mode == "settings":
		get_tree().change_scene_to_file("res://scenes/settings.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_button_pressed():
	var tween = create_tween()
	tween.tween_property(quit_button, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(quit_button, "scale", Vector2(1, 1), 0.1)
	tween.tween_callback(quit_game)

func quit_game():
	get_tree().quit()
