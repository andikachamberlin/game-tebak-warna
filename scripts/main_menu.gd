@tool
extends Control

@onready var start_button = $StartButton
@onready var stroop_button = $StroopButton
@onready var object_button = $ObjectButton
@onready var story_button = $StoryButton
@onready var platformer_button = $PlayPlatformerButton
@onready var emotion_button = $EmotionButton
@onready var light_button = $LightButton
@onready var settings_button = $SettingsButton
@onready var quit_button = $QuitButton
@onready var high_score_label = $HighScoreLabel

func _ready():
	# Localize Texts (Hardcoded Indonesian)
	start_button.text = "KLASIK"
	stroop_button.text = "TES OTAK"
	object_button.text = "TEBAK BENDA"
	story_button.text = "MODE CERITA"
	platformer_button.text = "PETUALANGAN"
	emotion_button.text = "WARNA EMOSI"
	light_button.text = "TEBAK CAHAYA"
	
	settings_button.text = "PENGATURAN"
	quit_button.text = "KELUAR"
	
	# Update High Score Display
	high_score_label.text = "Rekor Tertinggi: " + str(GameManager.high_score)
	
	setup_buttons()
	
	# Try to play music
	var bgm_path = "res://assets/music/bgm.mp3" # User should provide this
	if FileAccess.file_exists(bgm_path):
		var music = load(bgm_path)
		AudioManager.play_music(music)

func setup_buttons():
	var buttons = [
		start_button, stroop_button, object_button, story_button,
		platformer_button, emotion_button, light_button,
		settings_button, quit_button
	]
	
	for btn in buttons:
		btn.scale = Vector2.ZERO
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	var delay = 0.0
	for btn in buttons:
		tween.tween_property(btn, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(delay)
		delay += 0.05
		
		# Connect SFX
		if not btn.mouse_entered.is_connected(AudioManager.play_button_hover):
			btn.mouse_entered.connect(AudioManager.play_button_hover)
		if not btn.pressed.is_connected(AudioManager.play_button_click):
			btn.pressed.connect(AudioManager.play_button_click)

func _on_start_button_pressed():
	GameManager.current_mode = "classic"
	animate_button_press(start_button)

func _on_stroop_button_pressed():
	GameManager.current_mode = "stroop"
	animate_button_press(stroop_button)

func _on_object_button_pressed():
	GameManager.current_mode = "object"
	animate_button_press(object_button)

func _on_story_button_pressed():
	GameManager.current_mode = "story"
	animate_button_press(story_button)

func _on_play_platformer_button_pressed():
	GameManager.current_mode = "platformer"
	animate_button_press(platformer_button)

func _on_emotion_button_pressed():
	GameManager.current_mode = "emotion"
	animate_button_press(emotion_button)

func _on_light_button_pressed():
	GameManager.current_mode = "light"
	animate_button_press(light_button)

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
	elif GameManager.current_mode == "story":
		get_tree().change_scene_to_file("res://scenes/story_mode.tscn")
	elif GameManager.current_mode == "emotion":
		get_tree().change_scene_to_file("res://scenes/emotion_mode.tscn")
	elif GameManager.current_mode == "light":
		get_tree().change_scene_to_file("res://scenes/light_mode.tscn")
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
