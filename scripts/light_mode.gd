extends Control

@onready var color_display = $SafeArea/VBox/DisplayContainer/VBoxContainer/ObjectContainer/ColorViewport/SubViewport/ColorCube
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

# Resources
var font_resource = preload("res://assets/fonts/AmaticSC-Bold.ttf")

# Colors
var colors_easy = [
	{"name": "MERAH", "color": Color.RED},
	{"name": "HIJAU", "color": Color.GREEN},
	{"name": "BIRU", "color": Color.BLUE},
	{"name": "KUNING", "color": Color.YELLOW},
	{"name": "PUTIH", "color": Color.WHITE},
	{"name": "ABU-ABU", "color": Color.GRAY},
	{"name": "ORANYE", "color": Color("FF8000")},
	{"name": "COKLAT", "color": Color.BROWN}
]

var colors_hard = [
	{"name": "MERAH MUDA", "color": Color("FFC0CB")}, # Pink
	{"name": "BIRU MUDA", "color": Color("00FFFF")}, # Cyan
	{"name": "UNGU", "color": Color.PURPLE},
	{"name": "HITAM", "color": Color.BLACK}, # Can be tricky in dark lighting!
	{"name": "EMAS", "color": Color("FFD700")},
	{"name": "HIJAU LAUT", "color": Color("20B2AA")}, # Teal
	{"name": "MERAH BATA", "color": Color("B22222")},
	{"name": "KREM", "color": Color("F5F5DC")}
]

var conditions = [
	# Original / Natural Light
	{"name": "Malam Hari", "tint": Color(0.2, 0.2, 0.5, 1.0), "desc": "Benda ini ada di keheningan malam..."},
	{"name": "Ruang Gelap", "tint": Color(0.15, 0.15, 0.15, 1.0), "desc": "Lampu padam! Benda apa ini?"},
	{"name": "Senja", "tint": Color(0.8, 0.5, 0.3, 1.0), "desc": "Matahari terbenam menyinari benda ini..."},
	{"name": "Bawah Pohon", "tint": Color(0.1, 0.3, 0.1, 1.0), "desc": "Tertutup bayangan daun pohon..."},
	
	# Artificial Light
	{"name": "Lampu Disko Ungu", "tint": Color(0.6, 0.0, 0.8, 1.0), "desc": "Kena sorot lampu panggung..."},
	{"name": "Lampu Neon Merah", "tint": Color(0.8, 0.0, 0.0, 1.0), "desc": "Di bawah sinar neon merah..."},
	{"name": "Cahaya Lilin", "tint": Color(0.7, 0.5, 0.1, 1.0), "desc": "Hanya diterangi lilin kecil..."},
	{"name": "Lampu Jalan Kuning", "tint": Color(0.8, 0.7, 0.1, 1.0), "desc": "Di pinggir jalan malam hari..."},
	
	# Environmental
	{"name": "Dalam Air", "tint": Color(0.0, 0.4, 0.8, 1.0), "desc": "Tenggelam di dasar kolam..."},
	{"name": "Kabut Tebal", "tint": Color(0.7, 0.7, 0.7, 0.8), "desc": "Tertutup kabut putih..."},
	{"name": "Badai Pasir", "tint": Color(0.7, 0.5, 0.2, 1.0), "desc": "Terjebak badai gurun..."},
	{"name": "Hutan Magis", "tint": Color(0.2, 0.0, 0.4, 1.0), "desc": "Di hutan sihir yang gelap..."},
	
	# Filters / Effects
	{"name": "Foto Lama (Sepia)", "tint": Color(0.7, 0.5, 0.3, 1.0), "desc": "Seperti di foto zaman dulu..."},
	{"name": "Dunia Matrix", "tint": Color(0.0, 1.0, 0.0, 1.0), "desc": "Masuk ke dalam komputer..."},
	{"name": "Negatif Film", "tint": Color(0.2, 0.2, 0.2, 1.0), "desc": "Seperti klise foto negatif..."} # Tricky!
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
	
	# Determine color pool
	var pool = colors_easy.duplicate()
	if score >= 10:
		pool += colors_hard
	
	var object_data = pool.pick_random()
	var condition = conditions.pick_random()
	
	current_round = {
		"object": object_data,
		"condition": condition
	}
	
	# Apply 3D Cube Color and Tint
	color_display.set_color(object_data["color"])
	# Use modulate on the ViewportContainer or Cube to tint it
	$SafeArea/VBox/DisplayContainer/VBoxContainer/ObjectContainer/ColorViewport.modulate = condition["tint"]
	
	# Play Jelly Animation
	color_display.jelly_bounce()
	
	condition_label.text = condition["desc"] + "\n(" + condition["name"] + ")"
	
	setup_buttons(pool)

func setup_buttons(pool):
	for child in buttons_container.get_children():
		child.queue_free()
	
	var answers = pool.duplicate()
	answers.shuffle()
	
	# Limit buttons if pool is large
	if answers.size() > 6:
		var limited_answers = []
		limited_answers.append(current_round["object"]) # Ensure correct answer
		
		for c in answers:
			if c["name"] != current_round["object"]["name"] and limited_answers.size() < 6:
				limited_answers.append(c)
		
		limited_answers.shuffle()
		answers = limited_answers
	
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
		
		# Load Font and Add BOLD Outline
		var font_file = load("res://assets/fonts/AmaticSC-Bold.ttf")
		btn.add_theme_font_override("font", font_file)
		btn.add_theme_font_size_override("font_size", 40)
		btn.add_theme_constant_override("outline_size", 2) # Adding Outline for Bold effect
		
		if color_data["color"].get_luminance() > 0.5:
			btn.add_theme_color_override("font_color", Color.BLACK)
			btn.add_theme_color_override("font_outline_color", Color.BLACK) # Bold same color
		else:
			btn.add_theme_color_override("font_color", Color.WHITE)
			btn.add_theme_color_override("font_outline_color", Color.BLACK) # White text, Black outline for contrast
			
		# Connect SFX
		# btn.mouse_entered.connect(AudioManager.play_button_hover) # Disabled per user request

		
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
	# Remove tint to reveal true color
	tween.tween_property($SafeArea/VBox/DisplayContainer/VBoxContainer/ObjectContainer/ColorViewport, "modulate", Color.WHITE, 0.5)
	
	update_score(score + 1)
	
	tween.tween_interval(1.0)
	tween.tween_callback(next_level)

func handle_wrong():
	AudioManager.play_failed()
	feedback_label.text = "Salah... Itu tadi " + current_round["object"]["name"]
	feedback_label.modulate = Color.RED
	
	var tween = create_tween()
	# Remove tint to reveal true color
	tween.tween_property($SafeArea/VBox/DisplayContainer/VBoxContainer/ObjectContainer/ColorViewport, "modulate", Color.WHITE, 0.5)
	
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
	
	var vbox = $GameOverPanel/Margin/VBoxContainer
	
	# Clear existing children to rebuild UI cleanly
	for child in vbox.get_children():
		child.queue_free()
		
	# 1. Title Label
	var title = Label.new()
	title.text = "PERMAINAN SELESAI"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", font_resource)
	title.add_theme_font_size_override("font_size", 50)
	title.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
	vbox.add_child(title)
	
	# 2. Score Label
	var score_lbl = Label.new()
	score_lbl.text = "SKOR: " + str(score)
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_lbl.add_theme_font_override("font", font_resource)
	score_lbl.add_theme_font_size_override("font_size", 100)
	score_lbl.add_theme_color_override("font_color", Color(0, 0, 0))
	vbox.add_child(score_lbl)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(spacer)
	
	# 3. Restart Button (Green)
	var restart_btn = Button.new()
	restart_btn.text = "MAIN LAGI"
	restart_btn.custom_minimum_size = Vector2(0, 80)
	
	var style_start = StyleBoxFlat.new()
	style_start.bg_color = Color("4CAF50") # Green
	style_start.set_corner_radius_all(20)
	style_start.shadow_size = 5
	style_start.shadow_offset = Vector2(0, 4)
	style_start.shadow_color = Color(0, 0, 0, 0.2)
	
	var style_start_hover = style_start.duplicate()
	style_start_hover.bg_color = Color("45a049")
	
	restart_btn.add_theme_stylebox_override("normal", style_start)
	restart_btn.add_theme_stylebox_override("hover", style_start_hover)
	restart_btn.add_theme_stylebox_override("pressed", style_start)
	restart_btn.add_theme_font_override("font", font_resource)
	restart_btn.add_theme_font_size_override("font_size", 45)
	
	restart_btn.pressed.connect(_on_restart_button_pressed)
	vbox.add_child(restart_btn)
	
	# 4. Menu Button (Orange/Red)
	var menu_btn = Button.new()
	menu_btn.text = "MENU UTAMA"
	menu_btn.custom_minimum_size = Vector2(0, 60)
	
	var style_menu = StyleBoxFlat.new()
	style_menu.bg_color = Color("FF7043") # Soft Red/Orange
	style_menu.set_corner_radius_all(20)
	
	var style_menu_hover = style_menu.duplicate()
	style_menu_hover.bg_color = Color("F4511E")
	
	menu_btn.add_theme_stylebox_override("normal", style_menu)
	menu_btn.add_theme_stylebox_override("hover", style_menu_hover)
	menu_btn.add_theme_stylebox_override("pressed", style_menu)
	menu_btn.add_theme_font_override("font", font_resource)
	menu_btn.add_theme_font_size_override("font_size", 35)
	
	menu_btn.pressed.connect(_on_main_menu_button_pressed)
	vbox.add_child(menu_btn)

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
