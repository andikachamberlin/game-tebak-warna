extends Control

@onready var story_label = $SafeArea/VBox/DisplayContainer/VBoxContainer/StoryLabel
@onready var buttons_container = $SafeArea/VBox/DisplayContainer/VBoxContainer/ButtonsGrid
@onready var score_label = $SafeArea/VBox/Header/ScorePanel/ScoreLabel
@onready var feedback_label = $SafeArea/VBox/DisplayContainer/VBoxContainer/FeedbackLabel
@onready var lives_label = $SafeArea/VBox/Header/LivesPanel/Container/LivesLabel
@onready var game_over_panel = $GameOverPanel
@onready var pause_overlay = $PauseOverlay

# Resources
var font_resource = preload("res://assets/fonts/AmaticSC-Bold.ttf")

var score = 0
var lives = 3
var current_quest = {}
var colors = [
	{"name": "MERAH", "color": Color.RED, "hex": "RED"},
	{"name": "HIJAU", "color": Color.GREEN, "hex": "GREEN"},
	{"name": "BIRU", "color": Color.BLUE, "hex": "BLUE"},
	{"name": "KUNING", "color": Color(1, 0.8, 0), "hex": "YELLOW"} # Gold-ish yellow
]

# Quest templates
var templates = [
	{"text": "Monster ini alergi warna {color}!\nJangan beri dia warna itu!", "type": "AVOID"},
	{"text": "Raja ingin jubah warna {color}!\nCari warnanya!", "type": "PICK"},
	{"text": "Jangan injak rumput yang warnanya {color}!", "type": "AVOID"},
	{"text": "Mobil balap ini warnanya {color}!\nYang mana mobilnya?", "type": "PICK"},
	{"text": "Awas! Lantai {color} itu lava panas!\nPilih yang aman!", "type": "AVOID"},
	{"text": "Kumpulkan bunga warna {color} untuk ramuan!", "type": "PICK"}
]

func _ready():
	randomize()
	game_over_panel.hide()
	pause_overlay.hide()
	lives = 3
	update_lives_ui()
	update_score(0)
	next_level()

func next_level():
	feedback_label.text = ""
	
	var template = templates.pick_random()
	var target_color_data = colors.pick_random()
	
	current_quest = {
		"type": template["type"],
		"target": target_color_data,
		"text": template["text"].format({"color": target_color_data["name"]})
	}
	
	story_label.text = current_quest["text"]
	setup_buttons()

func setup_buttons():
	for child in buttons_container.get_children():
		child.queue_free()
	
	var shuffled_colors = colors.duplicate()
	shuffled_colors.shuffle()
	
	buttons_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	for color_data in shuffled_colors:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(250, 150)
		btn.pivot_offset = Vector2(125, 75) # Half of size
		btn.scale = Vector2.ZERO
		
		var style = StyleBoxFlat.new()
		style.bg_color = color_data["color"]
		style.set_corner_radius_all(20)
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		
		# Connect SFX
		btn.mouse_entered.connect(AudioManager.play_button_hover)
		btn.pressed.connect(AudioManager.play_button_click)
		
		btn.pressed.connect(_on_color_selected.bind(color_data))
		buttons_container.add_child(btn)
		
		# Jelly/Elastic Animation
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _on_color_selected(selected_color_data):
	var is_correct = false
	
	if current_quest["type"] == "PICK":
		if selected_color_data["name"] == current_quest["target"]["name"]:
			is_correct = true
	elif current_quest["type"] == "AVOID":
		if selected_color_data["name"] != current_quest["target"]["name"]:
			is_correct = true
			
	if is_correct:
		handle_correct()
	else:
		handle_wrong()

func handle_correct():
	AudioManager.play_success()
	feedback_label.text = "BENAR!"
	feedback_label.modulate = Color.GREEN
	update_score(score + 1)
	
	var tween = create_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(next_level)

func handle_wrong():
	AudioManager.play_failed()
	feedback_label.text = "SALAH!"
	feedback_label.modulate = Color.RED
	lives -= 1
	update_lives_ui()
	
	if lives <= 0:
		game_over()
	else:
		# Maybe a short delay or shuffle? Let's just create new quest
		var tween = create_tween()
		tween.tween_interval(0.5)
		tween.tween_callback(next_level)

func update_score(val):
	score = val
	score_label.text = str(score)

func update_lives_ui():
	var hearts = ""
	for i in range(lives):
		hearts += "❤️"
	lives_label.text = "[center]" + hearts + "[/center]"

func game_over():
	game_over_panel.show()
	$GameOverPanel/Margin/VBoxContainer/FinalScoreLabel.text = "Skor: " + str(score)
	GameManager.update_high_score(score)

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_pause_button_pressed():
	pause_overlay.show()
	get_tree().paused = true

func _on_resume_button_pressed():
	pause_overlay.hide()
	get_tree().paused = false
