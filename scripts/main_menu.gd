@tool
extends Control

@onready var title_label = $CenterContainer/VBoxContainer/TitleBox/TitleLabel
@onready var start_button = $CenterContainer/VBoxContainer/StartButton
@onready var quit_button = $CenterContainer/VBoxContainer/QuitButton

func _ready():
	# Animate Title - Floating effect
	var tween = create_tween().set_loops()
	tween.tween_property(title_label, "rotation_degrees", 2.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(title_label, "rotation_degrees", -2.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	setup_buttons()

func setup_buttons():
	# Add hover/pressed distinct visuals if needed via script, 
	# but we handled most in Theme. 
	# Let's add simple popup animation on load for buttons
	start_button.pivot_offset = start_button.size / 2
	quit_button.pivot_offset = quit_button.size / 2
	
	start_button.scale = Vector2.ZERO
	quit_button.scale = Vector2.ZERO
	
	var tween = create_tween()
	tween.tween_interval(0.2)
	tween.tween_property(start_button, "scale", Vector2(1, 1), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.1)
	tween.tween_property(quit_button, "scale", Vector2(1, 1), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_start_button_pressed():
	# Button click animation
	var tween = create_tween()
	tween.tween_property(start_button, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(start_button, "scale", Vector2(1, 1), 0.1)
	tween.tween_callback(change_scene)

func change_scene():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_button_pressed():
	var tween = create_tween()
	tween.tween_property(quit_button, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(quit_button, "scale", Vector2(1, 1), 0.1)
	tween.tween_callback(quit_game)

func quit_game():
	get_tree().quit()
