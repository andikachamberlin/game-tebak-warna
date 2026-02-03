extends Control

@onready var color_display = $SafeArea/VBox/DisplayContainer/ColorDisplay
@onready var options_container = $SafeArea/VBox/OptionsContainer
@onready var feedback_label = $SafeArea/VBox/FeedbackLabel
@onready var score_label = $SafeArea/VBox/Header/ScorePanel/ScoreLabel
@onready var lives_label = $SafeArea/VBox/Header/LivesPanel/Container/LivesLabel
@onready var game_over_overlay = $GameOverOverlay
@onready var final_score_label = $GameOverOverlay/CenterContainer/Card/Margin/VBox/FinalScoreLabel
@onready var pause_overlay = $PauseOverlay
@onready var timer_bar = $SafeArea/VBox/TimerBar

@onready var background = $Background # Ensure this node exists or use $SafeArea/..
@onready var stroop_label = $SafeArea/VBox/DisplayContainer/ColorDisplay/StroopLabel

# Classic Colors (Level 1)
var colors_easy = [
	{"name": "MERAH", "color": Color.RED},
	{"name": "BIRU", "color": Color.BLUE},
	{"name": "HIJAU", "color": Color.GREEN},
	{"name": "KUNING", "color": Color.YELLOW},
	{"name": "UNGU", "color": Color.PURPLE},
	{"name": "ORANYE", "color": Color("FF8000")},
	{"name": "HITAM", "color": Color.BLACK},
	{"name": "PUTIH", "color": Color.WHITE},
	{"name": "COKLAT", "color": Color.BROWN}
]

# Hard Colors (Similar shades - Level 2+)
var colors_hard = [
	{"name": "MERAH TUA", "color": Color("8B0000")},
	{"name": "MERAH BATA", "color": Color("B22222")},
	{"name": "BIRU LAUT", "color": Color("000080")},
	{"name": "BIRU LANGIT", "color": Color("87CEEB")},
	{"name": "HIJAU LUMUT", "color": Color("556B2F")},
	{"name": "HIJAU MUDA", "color": Color("90EE90")},
	{"name": "ABU-ABU", "color": Color.GRAY},
	{"name": "ABU MUDA", "color": Color.LIGHT_GRAY},
	{"name": "MAGENTA", "color": Color.MAGENTA},
	{"name": "NILA", "color": Color.INDIGO}
]

# Objects Data (Name -> Intrinsic Color)
var objects_data = [
	{"name": "PISANG", "answer": "KUNING", "color": Color.YELLOW},
	{"name": "APEL", "answer": "MERAH", "color": Color.RED},
	{"name": "LANGIT", "answer": "BIRU", "color": Color.BLUE},
	{"name": "RUMPUT", "answer": "HIJAU", "color": Color.GREEN},
	{"name": "AWAN", "answer": "PUTIH", "color": Color.WHITE},
	{"name": "ARANG", "answer": "HITAM", "color": Color.BLACK},
	{"name": "JERUK", "answer": "ORANYE", "color": Color("FF8000")},
	{"name": "ANGGUR", "answer": "UNGU", "color": Color.PURPLE},
	{"name": "KAYU", "answer": "COKLAT", "color": Color.BROWN},
	{"name": "DARAH", "answer": "MERAH", "color": Color.RED},
	{"name": "LAUT", "answer": "BIRU", "color": Color.BLUE},
	{"name": "DAUN", "answer": "HIJAU", "color": Color.GREEN},
	{"name": "SUSU", "answer": "PUTIH", "color": Color.WHITE},
	{"name": "ASPAL", "answer": "HITAM", "color": Color.BLACK},
	{"name": "TANAH", "answer": "COKLAT", "color": Color.BROWN}
]

var current_question = {}
var score = 0
var lives = 3
var max_time = 15.0 # Starting time (relaxed)
var current_time = 0.0
var is_game_active = false
var current_level_color_set = []

func _ready():
	game_over_overlay.visible = false
	pause_overlay.visible = false
	pause_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	new_game()

func _process(delta):
	if is_game_active and lives > 0:
		current_time -= delta
		if current_time <= 0:
			current_time = 0
			handle_timeout()
		
		# Update UI
		timer_bar.value = (current_time / max_time) * 100
		
		# Color logic for timer (Green -> Red)
		var style = timer_bar.get_theme_stylebox("fill")
		if style:
			if current_time < (max_time * 0.3):
				style.bg_color = Color(1, 0.3, 0.3)
			else:
				style.bg_color = Color(1, 0.8, 0)

func new_game():
	get_tree().paused = false
	score = 0
	lives = 3
	max_time = 15.0
	update_score()
	update_lives()
	game_over_overlay.visible = false
	pause_overlay.visible = false
	current_level_color_set = colors_easy.duplicate()
	next_level()

func _on_restart_button_pressed():
	new_game()

func _on_home_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_pause_button_pressed():
	get_tree().paused = true
	pause_overlay.visible = true

func _on_resume_button_pressed():
	get_tree().paused = false
	pause_overlay.visible = false

func next_level():
	feedback_label.text = ""
	is_game_active = true
	
	# Determine Difficulty/Mode Settings
	var mode = GameManager.current_mode
	
	# Common scaling (Time) - Stroop mode can be slightly more generous or same
	max_time = max(3.0, 15.0 - (score * 0.1))
	current_time = max_time
	
	# Setup Question Pool
	if score >= 20 or mode == "stroop":
		current_level_color_set = colors_easy + colors_hard
	else:
		current_level_color_set = colors_easy
	
	if background:
		background.modulate = Color.WHITE # Default reset
	
	if mode == "classic":
		stroop_label.visible = false
		setup_classic_round()
	elif mode == "stroop":
		stroop_label.visible = true
		setup_stroop_round()
	elif mode == "object":
		stroop_label.visible = true
		setup_object_round()
	
	# Generate Options
	var options = []
	
	if mode == "object":
		# For object mode, options are COLORS (Strings/Names), not object dicts
		# current_question["answer"] is the Correct Color Name
		var correct_answer_name = current_question["answer"]
		
		# Find the full color dict for the correct answer
		var correct_color_dict = {}
		for c in colors_easy:
			if c["name"] == correct_answer_name:
				correct_color_dict = c
				break
		
		options.append(correct_color_dict)
		
		# Wrong options
		var wrong_pool = colors_easy.duplicate()
		var wrong_idx = -1
		for i in range(wrong_pool.size()):
			if wrong_pool[i]["name"] == correct_answer_name:
				wrong_idx = i
				break
		if wrong_idx != -1:
			wrong_pool.remove_at(wrong_idx)
			
		wrong_pool.shuffle()
		
		# Determine Difficulty (Amount of choices)
		var num_options = 2
		if score >= 10: num_options = 3
		if score >= 30: num_options = 4
		
		for i in range(num_options - 1):
			if wrong_pool.size() > i:
				options.append(wrong_pool[i])
				
		options.shuffle()
		
	else:
		# Classic/Stroop logic (unchanged)
		# Generate Options (Shared logic mostly, depends on current_question which is the CORRECT ANSWER)
		var num_options = 2
		if score >= 10: num_options = 3
		if score >= 30: num_options = 4
		
		options = [current_question]
		var wrong_options = current_level_color_set.duplicate()
		
		# FIX: Ensure current_question dict is correctly identified for removal
		var index_to_remove = -1
		for i in range(wrong_options.size()):
			if wrong_options[i]["name"] == current_question["name"]:
				index_to_remove = i
				break
		if index_to_remove != -1:
			wrong_options.remove_at(index_to_remove)
			
		wrong_options.shuffle()
		
		for i in range(num_options - 1):
			if wrong_options.size() > i:
				options.append(wrong_options[i])
		
		options.shuffle()
	
	# Setup Buttons
	for child in options_container.get_children():
		child.queue_free()
	
	# var hide_text_mode = (mode == "classic" and score >= 40 and randi() % 5 == 0) # Removing confusing feature
	
	for option in options:
		var btn = Button.new()
		# if hide_text_mode:
		# 	btn.text = "???"
		# else:
		btn.text = option["name"]
		
		style_button(btn)
		
		btn.pressed.connect(_on_answer_selected.bind(btn, option))
		options_container.add_child(btn)

func setup_classic_round():
	# Twist Logic for Classic
	# REMOVED: Randomized background color (User requested white background)
	# if score >= 20 and background:
	# 	var bg_tween = create_tween()
	# 	var random_bg = Color(randf(), randf(), randf()).darkened(0.5) 
	# 	bg_tween.tween_property(background, "modulate", random_bg, 0.5)
	
	var available_colors = current_level_color_set.duplicate()
	current_question = available_colors.pick_random()
	
	# Display Logic
	var tween = create_tween()
	tween.tween_property(color_display, "modulate:a", 0.0, 0.1)
	tween.tween_callback(func(): 
		color_display.modulate = current_question["color"]
	)
	tween.tween_property(color_display, "modulate:a", 1.0, 0.1)

func setup_stroop_round():
	# Stroop Logic: Text Name != Text Color (Ink)
	
	var available_colors = current_level_color_set.duplicate()
	current_question = available_colors.pick_random() # This is the INK COLOR (Answer)
	
	# Pick a word that creates conflict (Different from Ink Color)
	var conflicting_words = available_colors.duplicate()
	var remove_idx = -1
	for i in range(conflicting_words.size()):
		if conflicting_words[i]["name"] == current_question["name"]:
			remove_idx = i
			break
	if remove_idx != -1:
		conflicting_words.remove_at(remove_idx)
		
	var distraction = conflicting_words.pick_random() # This is the TEXT shown
	
	# Display Logic
	var tween = create_tween()
	tween.tween_property(color_display, "modulate:a", 0.0, 0.1)
	tween.tween_callback(func(): 
		color_display.modulate = current_question["color"] # Panel becomes Answer Color
		stroop_label.text = distraction["name"] # Text says something else
	)
	tween.tween_property(color_display, "modulate:a", 1.0, 0.1)

func setup_object_round():
	# Object Mode: Guess the intrinsic color of the object named
	var available_objects = objects_data.duplicate()
	
	current_question = available_objects.pick_random()
	
	# Visual Trickery (Level Up)
	var display_color = Color.WHITE # Default text color
	
	if score >= 10:
		# Twist: Text color is misleading (Stroop effect on Object)
		var random_color = colors_easy.pick_random()["color"]
		display_color = random_color
	else:
		# Level 1: Helpful color (Text color matches answer)
		display_color = current_question["color"]
	
	# Display Logic
	var tween = create_tween()
	tween.tween_property(color_display, "modulate:a", 0.0, 0.1)
	tween.tween_callback(func(): 
		color_display.modulate = display_color # Panel/Text Color
		stroop_label.text = current_question["name"] # Show Object Name
	)
	tween.tween_property(color_display, "modulate:a", 1.0, 0.1)

func style_button(btn):
	var custom_font = load("res://assets/fonts/AmaticSC-Bold.ttf")
	btn.add_theme_font_override("font", custom_font)
	btn.add_theme_font_size_override("font_size", 48) # Significantly larger font
	
	# Fake Bold using Outline of same color
	btn.add_theme_color_override("font_outline_color", Color(0.25, 0.25, 0.25))
	btn.add_theme_constant_override("outline_size", 2)
	
	btn.custom_minimum_size = Vector2(0, 120) # Taller button
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.pivot_offset = Vector2(0, 60) 
	
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color.WHITE
	style_normal.border_width_bottom = 10 # Thicker bottom border for 3D feel
	style_normal.border_color = Color(0.8, 0.8, 0.8)
	style_normal.corner_radius_top_left = 30
	style_normal.corner_radius_top_right = 30
	style_normal.corner_radius_bottom_right = 30
	style_normal.corner_radius_bottom_left = 30
	style_normal.shadow_color = Color(0, 0, 0, 0.05)
	style_normal.shadow_size = 10
	style_normal.shadow_offset = Vector2(0, 5)
	
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = Color(0.95, 0.95, 0.95)
	
	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = Color(0.9, 0.9, 0.9)
	style_pressed.border_width_top = 10
	style_pressed.border_width_bottom = 0
	style_pressed.border_color = Color(0, 0, 0, 0)
	style_pressed.shadow_size = 2
	style_pressed.shadow_offset = Vector2(0, 2)
	
	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("pressed", style_pressed)
	btn.add_theme_stylebox_override("focus", style_hover)
	# Fix: Set disabled style same as normal so unselected buttons don't change ugly
	btn.add_theme_stylebox_override("disabled", style_normal)
	
	# Dark Gray Text for better readability on white button
	btn.add_theme_color_override("font_color", Color(0.25, 0.25, 0.25))
	btn.add_theme_color_override("font_hover_color", Color(0.15, 0.15, 0.15))
	btn.add_theme_color_override("font_pressed_color", Color(0.1, 0.1, 0.1))
	btn.add_theme_color_override("font_disabled_color", Color(0.25, 0.25, 0.25))

func _on_answer_selected(btn_node, option):
	# Disable all buttons
	for child in options_container.get_children():
		child.disabled = true
	
	is_game_active = false
	
	if GameManager.current_mode == "object":
		# In Object Mode:
		# option is a COLOR DICT (e.g. {"name": "KUNING", "color": ...})
		# current_question is an OBJECT DICT (e.g. {"name": "PISANG", "answer": "KUNING"})
		# We must compare option["name"] with current_question["answer"]
		if option["name"] == current_question["answer"]:
			handle_correct(btn_node)
		else:
			handle_wrong(btn_node)
	else:
		# Classic/Stroop Mode:
		# option and current_question are identical dictionaries (same reference or content)
		if option == current_question:
			handle_correct(btn_node)
		else:
			handle_wrong(btn_node)

func handle_timeout():
	is_game_active = false
	Input.vibrate_handheld(500)
	feedback_label.text = "[center][shake rate=20 level=10]WAKTU HABIS![/shake][/center]"
	
	lives -= 1
	update_lives()
	
	# Disable all buttons
	for child in options_container.get_children():
		child.disabled = true
	
	await get_tree().create_timer(1.0).timeout
	
	if lives <= 0:
		game_over()
	else:
		next_level()

func handle_correct(btn_node):
	Input.vibrate_handheld(50)
	# Make button Green
	var style_correct = btn_node.get_theme_stylebox("pressed").duplicate()
	style_correct.bg_color = Color(0.2, 0.8, 0.4) # Green
	style_correct.border_color = Color(0.1, 0.6, 0.3)
	btn_node.add_theme_stylebox_override("disabled", style_correct)
	btn_node.add_theme_color_override("font_disabled_color", Color.WHITE)
	# Fake Bold for White Text on Green Button
	btn_node.add_theme_color_override("font_outline_color", Color.WHITE)
	btn_node.add_theme_constant_override("outline_size", 2)
	
	feedback_label.text = "[center][wave][font=res://assets/fonts/AmaticSC-Bold.ttf]BENAR WARNA " + option_name_to_bbcode(current_question["name"]) + "![/font][/wave][/center]"
	
	# Bonus score for speed
	var bonus = int(current_time)
	score += 10 + bonus
	update_score()
	create_confetti()
	
	var tween = create_tween()
	tween.tween_property(btn_node, "scale", Vector2(1.05, 1.05), 0.1)
	tween.tween_property(btn_node, "scale", Vector2(1.0, 1.0), 0.1)
	
	await get_tree().create_timer(1.2).timeout
	next_level()

func create_confetti():
	var confetti = CPUParticles2D.new()
	add_child(confetti)
	
	# Position: Center of screen approx
	confetti.position = Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y / 2)
	
	# Modern Confetti Settings
	confetti.amount = 80 # Increased density
	confetti.explosiveness = 0.9 # Quick burst
	confetti.lifetime = 3.0
	confetti.one_shot = true
	confetti.spread = 180 # Full circle
	confetti.gravity = Vector2(0, 400) # Fall down
	
	confetti.direction = Vector2(0, -1)
	confetti.initial_velocity_min = 300
	confetti.initial_velocity_max = 700
	
	# Rotation for 2D confetti feel
	confetti.angular_velocity_min = 100.0
	confetti.angular_velocity_max = 300.0
	
	# Size variation
	confetti.scale_amount_min = 8.0
	confetti.scale_amount_max = 16.0
	
	# Use squares/rects if we had a texture, but squares by default usage of particles in Godot 4 needs a texture or it's points. 
	# CPUParticles2D without texture draws squares by default.
	
	# Color: Nice pastel/vibrant mix
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([
		Color("FF6B6B"), # Red
		Color("4ECDC4"), # Teal
		Color("FFE66D"), # Yellow
		Color("FF9F1C"), # Orange
		Color("9DABDD")  # Periwinkle
	])
	confetti.color = Color.WHITE # Base is white, ramp applies color
	confetti.color_ramp = gradient
	
	# Hue variation for extra randomness
	confetti.hue_variation_min = -0.1
	confetti.hue_variation_max = 0.1
	
	confetti.emitting = true
	
	await get_tree().create_timer(3.0).timeout
	confetti.queue_free()

func handle_wrong(btn_node):
	Input.vibrate_handheld(400)
	# Make button Red
	var style_wrong = btn_node.get_theme_stylebox("pressed").duplicate()
	style_wrong.bg_color = Color(1.0, 0.3, 0.3) # Red
	style_wrong.border_color = Color(0.8, 0.2, 0.2)
	btn_node.add_theme_stylebox_override("disabled", style_wrong)
	btn_node.add_theme_color_override("font_disabled_color", Color.WHITE)
	
	lives -= 1
	update_lives()
	
	if lives <= 0:
		feedback_label.text = "[center][shake rate=20 level=10][font=res://assets/fonts/AmaticSC-Bold.ttf]YAH GAME OVER![/font][/shake][/center]"
		await get_tree().create_timer(1.0).timeout
		game_over()
	else:
		feedback_label.text = "[center][shake rate=20 level=10][font=res://assets/fonts/AmaticSC-Bold.ttf]YAH SALAH TEBAK...[/font][/shake][/center]"
		var tween = create_tween()
		tween.tween_property(btn_node, "position:x", btn_node.position.x + 15, 0.05)
		tween.tween_property(btn_node, "position:x", btn_node.position.x - 15, 0.05)
		tween.tween_property(btn_node, "position:x", btn_node.position.x, 0.05)
		
		await get_tree().create_timer(1.0).timeout
		
		feedback_label.text = ""
		
		is_game_active = true
		
		# Enable buttons again for retry
		for child in options_container.get_children():
			child.disabled = false

func game_over():
	final_score_label.text = "Nilai Akhir: " + str(score)
	game_over_overlay.visible = true
	GameManager.update_high_score(score)

func option_name_to_bbcode(color_name):
	return "[color=#E69500]" + color_name + "[/color]"

func update_score():
	score_label.text = str(score)

func update_lives():
	var heart_str = ""
	for i in range(lives):
		heart_str += "❤️"
	lives_label.text = heart_str
