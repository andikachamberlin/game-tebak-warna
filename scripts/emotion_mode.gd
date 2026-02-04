extends Control

@onready var emotion_label = $SafeArea/VBox/DisplayContainer/VBoxContainer/EmotionLabel
@onready var buttons_container = $SafeArea/VBox/DisplayContainer/VBoxContainer/ButtonsGrid
@onready var score_label = $SafeArea/VBox/Header/ScorePanel/ScoreLabel
@onready var feedback_label = $SafeArea/VBox/DisplayContainer/VBoxContainer/FeedbackLabel
@onready var explanation_label = $SafeArea/VBox/DisplayContainer/VBoxContainer/ExplanationLabel
@onready var lives_label = $SafeArea/VBox/Header/LivesPanel/Container/LivesLabel
@onready var game_over_panel = $GameOverPanel
@onready var pause_overlay = $PauseOverlay

var score = 0
var lives = 3
var current_question = {}

# Available colors in buttons
# Available colors
var colors_easy = [
	{"name": "MERAH", "color": Color.RED},
	{"name": "HIJAU", "color": Color.GREEN},
	{"name": "BIRU", "color": Color.BLUE},
	{"name": "KUNING", "color": Color(1, 0.8, 0)},
	{"name": "UNGU", "color": Color(0.6, 0.2, 0.8)},
	{"name": "HITAM", "color": Color.BLACK},
	{"name": "PUTIH", "color": Color.WHITE},
	{"name": "ORANYE", "color": Color("FF8000")},
	{"name": "COKLAT", "color": Color.BROWN}
]

var colors_hard = [
	{"name": "MERAH MUDA", "color": Color("FFC0CB")}, # Pink/Love
	{"name": "ABU-ABU", "color": Color.GRAY}, # Neutral/Sad
	{"name": "EMAS", "color": Color("FFD700")}, # Luxury/Victory
	{"name": "BIRU MUDA", "color": Color("00FFFF")}, # Calm/Cold
	{"name": "HIJAU TUA", "color": Color("006400")}, # Nature/Ency
	{"name": "MERAH TUA", "color": Color("8B0000")} # Anger/Danger
]

# Questions dataset
# Questions dataset
var questions_easy = [
	{
		"text": "Warna apa yang terasa DINGIN?",
		"answers": ["BIRU", "PUTIH", "UNGU", "BIRU MUDA"],
		"valid_explanation": "Betul! Warna sejuk seperti es!",
		"wrong_explanation": "Hmm, itu terasa hangat bagi banyak orang."
	},
	{
		"text": "Warna apa yang terasa MARAH?",
		"answers": ["MERAH", "HITAM", "MERAH TUA"],
		"valid_explanation": "Ya! Seperti api kemarahan!",
		"wrong_explanation": "Itu lebih terasa tenang atau ceria."
	},
	{
		"text": "Warna apa yang terasa TENANG?",
		"answers": ["HIJAU", "BIRU", "PUTIH", "BIRU MUDA"],
		"valid_explanation": "Benar, seperti alam atau langit.",
		"wrong_explanation": "Warna itu terlalu bersemangat untuk tenang."
	},
	{
		"text": "Warna apa yang terasa PANAS?",
		"answers": ["MERAH", "KUNING", "ORANYE"],
		"valid_explanation": "Tepat! Seperti matahari atau api.",
		"wrong_explanation": "Itu justru warna yang sejuk."
	},
	{
		"text": "Warna apa yang terasa BAHAGIA?",
		"answers": ["KUNING", "HIJAU", "BIRU", "ORANYE", "MERAH MUDA"],
		"valid_explanation": "Ceria sekali warnanya!",
		"wrong_explanation": "Warna itu agak gelap untuk bahagia."
	},
	{
		"text": "Warna apa yang terasa MISTERIUS?",
		"answers": ["UNGU", "HITAM", "ABU-ABU"],
		"valid_explanation": "Sangat misterius...",
		"wrong_explanation": "Itu terlalu terang untuk misteri."
	},
	{
		"text": "Warna apa yang terasa BERANI?",
		"answers": ["MERAH", "HITAM", "ORANYE"],
		"valid_explanation": "Gagah dan berani!",
		"wrong_explanation": "Warna itu terlihat pemalu."
	},
	{
		"text": "Warna apa yang terasa SEGAR?",
		"answers": ["HIJAU", "KUNING", "BIRU MUDA", "ORANYE"],
		"valid_explanation": "Segar seperti buah atau daun!",
		"wrong_explanation": "Itu terasa agak layu atau gelap."
	}
]

var questions_hard = [
	{
		"text": "Warna apa yang terasa CINTA?",
		"answers": ["MERAH MUDA", "MERAH"],
		"valid_explanation": "Romantis sekali!",
		"wrong_explanation": "Kurang romantis rasanya."
	},
	{
		"text": "Warna apa yang terasa SEDIH?",
		"answers": ["BIRU", "ABU-ABU", "HITAM"],
		"valid_explanation": "Melankolis dan sendu.",
		"wrong_explanation": "Itu terlalu ceria untuk sedih."
	},
	{
		"text": "Warna apa yang terasa KAYA / MEWAH?",
		"answers": ["EMAS", "UNGU", "HITAM", "MERAH TUA"],
		"valid_explanation": "Elegan dan mahal!",
		"wrong_explanation": "Terlihat biasa saja."
	},
	{
		"text": "Warna apa yang terasa SAKIT?",
		"answers": ["HIJAU", "KUNING", "ABU-ABU"], # Green/Yellow often associated with sickness/nausea in cartoons
		"valid_explanation": "Pucat dan tidak sehat.",
		"wrong_explanation": "Itu terlihat sehat dan bugar."
	},
	{
		"text": "Warna apa yang terasa MANIS?",
		"answers": ["MERAH MUDA", "UNGU", "ORANYE"],
		"valid_explanation": "Manis seperti permen!",
		"wrong_explanation": "Rasanya pahit atau tawar."
	},
	{
		"text": "Warna apa yang terasa IRI HATI?",
		"answers": ["HIJAU", "HIJAU TUA"], # Green with envy
		"valid_explanation": "Hijau karena cemburu!",
		"wrong_explanation": "Bukan warna cemburu."
	},
	{
		"text": "Warna apa yang terasa SUCI / BERSIH?",
		"answers": ["PUTIH", "BIRU MUDA"],
		"valid_explanation": "Murni dan bersih.",
		"wrong_explanation": "Terlihat kotor atau gelap."
	},
	{
		"text": "Warna apa yang terasa BERACUN?",
		"answers": ["UNGU", "HIJAU", "HIJAU TUA"],
		"valid_explanation": "Awas berbahaya!",
		"wrong_explanation": "Itu terlihat aman dimakan."
	},
	{
		"text": "Warna apa yang terasa TUA / KUNO?",
		"answers": ["COKLAT", "ABU-ABU", "EMAS"],
		"valid_explanation": "Klasik dan antik.",
		"wrong_explanation": "Terlihat terlalu modern."
	},
	{
		"text": "Warna apa yang terasa LEMAH?",
		"answers": ["ABU-ABU", "PUTIH", "BIRU MUDA"],
		"valid_explanation": "Lembut dan rapuh.",
		"wrong_explanation": "Itu terlihat kuat!"
	}
]

func _ready():
	randomize()
	game_over_panel.hide()
	pause_overlay.hide()
	explanation_label.text = ""
	lives = 3
	update_lives_ui()
	update_score(0)
	next_level()

func next_level():
	feedback_label.text = ""
	explanation_label.text = ""
	
	# Select question pool
	var pool = questions_easy
	if score >= 10:
		pool += questions_hard
	
	current_question = pool.pick_random()
	emotion_label.text = current_question["text"]
	
	setup_buttons()

func setup_buttons():
	for child in buttons_container.get_children():
		child.queue_free()
	
	# Determine available colors based on score
	var available_colors = colors_easy.duplicate()
	if score >= 10:
		available_colors += colors_hard
	
	# Pick 4 random colors to show choices
	var choices = available_colors.duplicate()
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
		for c in available_colors:
			if c["name"] == correct_color_name:
				correct_color_data = c
				break
		# Replace first choice
		if correct_color_data:
			choices[0] = correct_color_data
			choices.shuffle()
	
	buttons_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	for color_data in choices:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(250, 150)
		btn.pivot_offset = Vector2(125, 75)
		btn.scale = Vector2.ZERO
		
		var style = StyleBoxFlat.new()
		style.bg_color = color_data["color"]
		style.set_corner_radius_all(20)
		style.border_width_bottom = 10
		style.border_color = color_data["color"].darkened(0.2)
		
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		
		# Connect SFX
		# btn.mouse_entered.connect(AudioManager.play_button_hover) # Disabled per user request

		
		btn.pressed.connect(_on_color_selected.bind(color_data))
		buttons_container.add_child(btn)
		
		# Jelly/Elastic Animation
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _on_color_selected(selected_color_data):
	var answer = selected_color_data["name"]
	var is_correct = answer in current_question["answers"]
	
	if is_correct:
		handle_correct()
	else:
		handle_wrong()

func handle_correct():
	AudioManager.play_success()
	feedback_label.text = "COCOK!"
	feedback_label.modulate = Color.GREEN
	explanation_label.text = current_question["valid_explanation"]
	
	update_score(score + 1)
	
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_callback(next_level)

func handle_wrong():
	AudioManager.play_failed()
	feedback_label.text = "KURANG TEPAT..."
	feedback_label.modulate = Color.RED
	explanation_label.text = current_question["wrong_explanation"]
	
	lives -= 1
	update_lives_ui()
	
	if lives <= 0:
		var tween = create_tween()
		tween.tween_interval(2.0)
		tween.tween_callback(game_over)
	else:
		var tween = create_tween()
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
