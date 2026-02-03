extends Control

@onready var emotion_label = $CenterContainer/VBoxContainer/EmotionLabel
@onready var buttons_container = $CenterContainer/VBoxContainer/ButtonsGrid
@onready var score_label = $HUD/ScoreLabel
@onready var feedback_label = $CenterContainer/VBoxContainer/FeedbackLabel
@onready var explanation_label = $CenterContainer/VBoxContainer/ExplanationLabel
@onready var game_over_panel = $GameOverPanel

var score = 0
var current_question = {}

# Available colors in buttons
var colors = [
	{"name": "MERAH", "color": Color.RED},
	{"name": "HIJAU", "color": Color.GREEN},
	{"name": "BIRU", "color": Color.BLUE},
	{"name": "KUNING", "color": Color(1, 0.8, 0)}, # Yellow
	{"name": "UNGU", "color": Color(0.6, 0.2, 0.8)},
	{"name": "HITAM", "color": Color.BLACK},
	{"name": "PUTIH", "color": Color.WHITE}
]

# Questions dataset
# answers: list of color names considered "correct" or "relatable"
# explanation: text to show after decision
var questions = [
	{
		"text": "Warna apa yang terasa DINGIN?",
		"answers": ["BIRU", "PUTIH", "UNGU"],
		"valid_explanation": "Betul! Warna sejuk seperti es!",
		"wrong_explanation": "Hmm, itu terasa hangat bagi banyak orang."
	},
	{
		"text": "Warna apa yang terasa MARAH?",
		"answers": ["MERAH", "HITAM"],
		"valid_explanation": "Ya! Seperti api kemarahan!",
		"wrong_explanation": "Itu lebih terasa tenang atau ceria."
	},
	{
		"text": "Warna apa yang terasa TENANG?",
		"answers": ["HIJAU", "BIRU", "PUTIH"],
		"valid_explanation": "Benar, seperti alam atau langit.",
		"wrong_explanation": "Warna itu terlalu bersemangat untuk tenang."
	},
	{
		"text": "Warna apa yang terasa PANAS?",
		"answers": ["MERAH", "KUNING", "ORANYE"], # Orange not in default colors list yet, maybe stick to Red/Yellow
		"valid_explanation": "Tepat! Seperti matahari atau api.",
		"wrong_explanation": "Itu justru warna yang sejuk."
	},
	{
		"text": "Warna apa yang terasa BAHAGIA?",
		"answers": ["KUNING", "HIJAU", "BIRU"], # Relaxed definition
		"valid_explanation": "Ceria sekali warnanya!",
		"wrong_explanation": "Warna itu agak gelap untuk bahagia."
	},
	{
		"text": "Warna apa yang terasa MISTERIUS?",
		"answers": ["UNGU", "HITAM"],
		"valid_explanation": "Sangat misterius...",
		"wrong_explanation": "Itu terlalu terang untuk misteri."
	}
]

func _ready():
	randomize()
	game_over_panel.hide()
	explanation_label.text = ""
	update_score(0)
	next_level()

func next_level():
	feedback_label.text = ""
	explanation_label.text = ""
	
	current_question = questions.pick_random()
	emotion_label.text = current_question["text"]
	
	setup_buttons()

func setup_buttons():
	for child in buttons_container.get_children():
		child.queue_free()
	
	# Pick 4 random colors to show choices
	var choices = colors.duplicate()
	choices.shuffle()
	choices = choices.slice(0, 4)
	
	# Ensure at least one correct answer exists in choices
	var has_answer = false
	for c in choices:
		if c["name"] in current_question["answers"]:
			has_answer = true
			break
	
	# If no correct answer in random pick, force add one
	if not has_answer:
		# Find a correct color from full list
		var correct_color_name = current_question["answers"].pick_random()
		var correct_color_data
		for c in colors:
			if c["name"] == correct_color_name:
				correct_color_data = c
				break
		# Replace first choice
		if correct_color_data:
			choices[0] = correct_color_data
			choices.shuffle()
	
	for color_data in choices:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(250, 150)
		
		var style = StyleBoxFlat.new()
		style.bg_color = color_data["color"]
		style.set_corner_radius_all(20)
		style.border_width_bottom = 10
		style.border_color = color_data["color"].darkened(0.2)
		
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		
		btn.pressed.connect(_on_color_selected.bind(color_data))
		buttons_container.add_child(btn)

func _on_color_selected(selected_color_data):
	var answer = selected_color_data["name"]
	var is_correct = answer in current_question["answers"]
	
	if is_correct:
		handle_correct()
	else:
		handle_wrong()

func handle_correct():
	feedback_label.text = "COCOK!"
	feedback_label.modulate = Color.GREEN
	explanation_label.text = current_question["valid_explanation"]
	update_score(score + 1)
	
	var tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_callback(next_level)

func handle_wrong():
	# In this mode, maybe we strictly don't game over?
	# "User: Nggak ada jawaban mutlak -> bikin diskusi & replay"
	# So let's just give feedback and move on, or give 'strike'?
	# Let's treat it as educational: Show explanation, no points, next level.
	feedback_label.text = "MENARIK..."
	feedback_label.modulate = Color.ORANGE
	explanation_label.text = current_question["wrong_explanation"]
	
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_callback(next_level)

func update_score(val):
	score = val
	score_label.text = str(score)

func _on_restart_button_pressed():
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
