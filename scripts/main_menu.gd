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
	# Update High Score Display
	high_score_label.text = "Rekor Tertinggi: " + str(GameManager.high_score)
	
	setup_buttons()
	
	# Try to play music
	var bgm_path = "res://assets/music/bgm.mp3" # User should provide this
	if FileAccess.file_exists(bgm_path):
		var music = load(bgm_path)
		AudioManager.play_music(music)

func setup_buttons():
	start_button.pivot_offset = start_button.size / 2
	stroop_button.pivot_offset = stroop_button.size / 2
	object_button.pivot_offset = object_button.size / 2
	story_button.pivot_offset = story_button.size / 2
	platformer_button.pivot_offset = platformer_button.size / 2
	emotion_button.pivot_offset = emotion_button.size / 2
	light_button.pivot_offset = light_button.size / 2
	settings_button.pivot_offset = settings_button.size / 2
	quit_button.pivot_offset = quit_button.size / 2
	
	start_button.scale = Vector2.ZERO
	stroop_button.scale = Vector2.ZERO
	object_button.scale = Vector2.ZERO
	story_button.scale = Vector2.ZERO
	platformer_button.scale = Vector2.ZERO
	emotion_button.scale = Vector2.ZERO
	light_button.scale = Vector2.ZERO
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
	tween.tween_property(story_button, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.1)
	tween.tween_property(platformer_button, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.1)
	tween.tween_property(emotion_button, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.1)
	tween.tween_property(light_button, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
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
