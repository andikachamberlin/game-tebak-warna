extends Control

@onready var object_rect = $SafeArea/VBox/DisplayContainer/VBoxContainer/ObjectContainer/ObjectRect
@onready var light_overlay = $SafeArea/VBox/DisplayContainer/VBoxContainer/ObjectContainer/LightOverlay
@onready var prompt_label = $SafeArea/VBox/DisplayContainer/VBoxContainer/PromptLabel
@onready var condition_label = $SafeArea/VBox/DisplayContainer/VBoxContainer/ConditionLabel
@onready var buttons_container = $SafeArea/VBox/DisplayContainer/VBoxContainer/ButtonsGrid
@onready var feedback_label = $SafeArea/VBox/DisplayContainer/VBoxContainer/FeedbackLabel
@onready var score_label = $SafeArea/VBox/Header/ScorePanel/ScoreLabel
@onready var lives_label = $SafeArea/VBox/Header/LivesPanel/Container/LivesLabel
@onready var game_over_panel = $GameOverPanel
@onready var pause_overlay = $PauseOverlay

var score = 0
var lives = 3
var current_round = {}

var colors = [
	{"name": "MERAH", "color": Color.RED},
	{"name": "HIJAU", "color": Color.GREEN},
	{"name": "BIRU", "color": Color.BLUE},
	{"name": "KUNING", "color": Color.YELLOW},
	{"name": "PUTIH", "color": Color.WHITE},
	{"name": "ABU-ABU", "color": Color.GRAY}
]

var conditions = [
	{
		"name": "Malam Hari",
		"tint": Color(0.2, 0.2, 0.5, 1.0),
		"desc": "Benda ini ada di keheningan malam..."
	},
	{
		"name": "Ruang Gelap",
		"tint": Color(0.15, 0.15, 0.15, 1.0),
		"desc": "Lampu padam! Benda apa ini?"
	},
	{
		"name": "Senja",
		"tint": Color(0.8, 0.5, 0.3, 1.0),
		"desc": "Matahari terbenam menyinari benda ini..."
	},
	{
		"name": "Bawah Pohon Rindang",
		"tint": Color(0.1, 0.3, 0.1, 1.0),
		"desc": "Tertutup bayangan daun pohon..."
	},
	{
		"name": "Lampu Disko Ungu",
		"tint": Color(0.6, 0.0, 0.8, 1.0),
		"desc": "Kena sorot lampu panggung..."
	}
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
	
	var object_data = colors.pick_random()
	var condition = conditions.pick_random()
	
	current_round = {
		"object": object_data,
		"condition": condition
	}
	
	object_rect.color = object_data["color"]
	object_rect.modulate = condition["tint"]
	
	condition_label.text = condition["desc"] + "\n(" + condition["name"] + ")"
	
	setup_buttons()

func setup_buttons():
	for child in buttons_container.get_children():
		child.queue_free()
	
	var answers = colors.duplicate()
	answers.shuffle()
	
	buttons_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	for color_data in answers:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(250, 100)
		btn.pivot_offset = Vector2(125, 50)
		btn.scale = Vector2.ZERO
		
		var style = StyleBoxFlat.new()
		style.bg_color = color_data["color"]
		style.set_corner_radius_all(15)
		style.border_width_bottom = 5
		style.border_color = Color.BLACK
		
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		
		btn.text = color_data["name"]
		
		# Load Font
		var font_file = load("res://assets/fonts/AmaticSC-Bold.ttf")
		btn.add_theme_font_override("font", font_file)
		btn.add_theme_font_size_override("font_size", 40)
		
		if color_data["color"].get_luminance() > 0.5:
			btn.add_theme_color_override("font_color", Color.BLACK)
		else:
			btn.add_theme_color_override("font_color", Color.WHITE)
			
		# Connect SFX
		btn.mouse_entered.connect(AudioManager.play_button_hover)
		btn.pressed.connect(AudioManager.play_button_click)
		
		btn.pressed.connect(_on_answer_selected.bind(color_data))
		buttons_container.add_child(btn)
		
		# Jelly/Elastic Animation
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _on_answer_selected(selected_color):
	if selected_color["name"] == current_round["object"]["name"]:
		handle_correct()
	else:
		handle_wrong()

func handle_correct():
	AudioManager.play_success()
	feedback_label.text = "HEBAT! Mata yang tajam!"
	feedback_label.modulate = Color.GREEN
	
	var tween = create_tween()
	tween.tween_property(object_rect, "modulate", Color.WHITE, 0.5)
	
	update_score(score + 1)
	
	tween.tween_interval(1.0)
	tween.tween_callback(next_level)

func handle_wrong():
	AudioManager.play_failed()
	feedback_label.text = "Salah... Itu tadi " + current_round["object"]["name"]
	feedback_label.modulate = Color.RED
	
	var tween = create_tween()
	tween.tween_property(object_rect, "modulate", Color.WHITE, 0.5)
	
	lives -= 1
	update_lives_ui()
	
	if lives <= 0:
		tween.tween_interval(2.0)
		tween.tween_callback(game_over)
	else:
		tween.tween_interval(2.0)
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
