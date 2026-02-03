extends Control

@onready var color_display = $SafeArea/VBox/DisplayContainer/ColorDisplay
@onready var options_container = $SafeArea/VBox/OptionsContainer
@onready var feedback_label = $SafeArea/VBox/FeedbackLabel
@onready var score_label = $SafeArea/VBox/Header/ScorePanel/ScoreLabel
@onready var lives_label = $SafeArea/VBox/Header/LivesLabel
@onready var game_over_overlay = $GameOverOverlay
@onready var final_score_label = $GameOverOverlay/CenterContainer/VBox/FinalScoreLabel

var colors = [
	{"name": "MERAH", "color": Color.RED},
	{"name": "BIRU", "color": Color.BLUE},
	{"name": "HIJAU", "color": Color.GREEN},
	{"name": "KUNING", "color": Color.YELLOW},
	{"name": "UNGU", "color": Color.PURPLE},
	{"name": "ORANYE", "color": Color("FF8000")}, # Orange
	{"name": "HITAM", "color": Color.BLACK},
	{"name": "PUTIH", "color": Color.WHITE},
	{"name": "COKLAT", "color": Color.BROWN},
	{"name": "MERAH MUDA", "color": Color.PINK}
]

var current_question = {}
var score = 0
var lives = 3

func _ready():
	game_over_overlay.visible = false
	new_game()

func new_game():
	score = 0
	lives = 3
	update_score()
	update_lives()
	game_over_overlay.visible = false
	next_level()

func _on_restart_button_pressed():
	new_game()

func _on_home_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func next_level():
	feedback_label.text = ""
	
	# Pick random color for current_question
	var available_colors = colors.duplicate()
	if current_question:
		available_colors.erase(current_question) # Avoid same color twice
	
	current_question = available_colors.pick_random()
	
	# Animate color change
	var tween = create_tween()
	tween.tween_property(color_display, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func(): 
		color_display.modulate = current_question["color"]
	)
	tween.tween_property(color_display, "modulate:a", 1.0, 0.2)
	
	# Determine difficulty based on score
	var num_options = 2
	if score >= 30:
		num_options = 3
	if score >= 80:
		num_options = 4
	
	# Generate options
	var options = [current_question]
	var wrong_options = colors.duplicate()
	wrong_options.erase(current_question)
	wrong_options.shuffle()
	
	# Add wrong options
	for i in range(num_options - 1):
		if wrong_options.size() > i:
			options.append(wrong_options[i])
	
	options.shuffle()
	
	# Setup buttons
	for child in options_container.get_children():
		child.queue_free()
	
	for option in options:
		var btn = Button.new()
		btn.text = option["name"]
		
		# Playful Button Styles
		btn.add_theme_font_size_override("font_size", 28)
		btn.custom_minimum_size = Vector2(0, 80)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.pivot_offset = Vector2(0, 40) 
		
		# Style Normal
		var style_normal = StyleBoxFlat.new()
		style_normal.bg_color = Color.WHITE
		style_normal.border_width_bottom = 8
		style_normal.border_color = Color(0.8, 0.8, 0.8)
		style_normal.corner_radius_top_left = 20
		style_normal.corner_radius_top_right = 20
		style_normal.corner_radius_bottom_right = 20
		style_normal.corner_radius_bottom_left = 20
		style_normal.shadow_color = Color(0, 0, 0, 0.05)
		style_normal.shadow_size = 10
		style_normal.shadow_offset = Vector2(0, 5)
		
		var style_hover = style_normal.duplicate()
		style_hover.bg_color = Color(0.95, 0.95, 0.95)
		
		var style_pressed = style_normal.duplicate()
		style_pressed.bg_color = Color(0.9, 0.9, 0.9)
		style_pressed.border_width_top = 8
		style_pressed.border_width_bottom = 0
		style_pressed.border_color = Color(0, 0, 0, 0)
		style_pressed.shadow_size = 2
		style_pressed.shadow_offset = Vector2(0, 2)
		
		btn.add_theme_stylebox_override("normal", style_normal)
		btn.add_theme_stylebox_override("hover", style_hover)
		btn.add_theme_stylebox_override("pressed", style_pressed)
		btn.add_theme_stylebox_override("focus", style_hover)
		
		# Text Colors
		btn.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
		btn.add_theme_color_override("font_hover_color", Color(0.2, 0.2, 0.2))
		btn.add_theme_color_override("font_pressed_color", Color(0.2, 0.2, 0.2))
		
		btn.pressed.connect(_on_answer_selected.bind(btn, option))
		options_container.add_child(btn)

func _on_answer_selected(btn_node, option):
	# Disable all buttons
	for child in options_container.get_children():
		child.disabled = true
		
	if option == current_question:
		handle_correct(btn_node)
	else:
		handle_wrong(btn_node)

func handle_correct(btn_node):
	# Make button Green
	var style_correct = btn_node.get_theme_stylebox("pressed").duplicate()
	style_correct.bg_color = Color(0.2, 0.8, 0.4) # Green
	style_correct.border_color = Color(0.1, 0.6, 0.3)
	btn_node.add_theme_stylebox_override("disabled", style_correct)
	btn_node.add_theme_color_override("font_disabled_color", Color.WHITE)
	
	feedback_label.text = "[center][wave]BENAR WARNA " + option_name_to_bbcode(current_question["name"]) + "![/wave][/center]"
	
	score += 10
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
	confetti.position = Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y / 2)
	confetti.amount = 50
	confetti.explosiveness = 1.0
	confetti.lifetime = 2.0
	confetti.one_shot = true
	confetti.spread = 180
	confetti.gravity = Vector2(0, 500)
	confetti.initial_velocity_min = 300
	confetti.initial_velocity_max = 600
	confetti.scale_amount_min = 10
	confetti.scale_amount_max = 20
	confetti.color = Color.CYAN 
	
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW, Color.MAGENTA])
	confetti.color_ramp = gradient
	
	confetti.emitting = true
	await get_tree().create_timer(2.0).timeout
	confetti.queue_free()

func handle_wrong(btn_node):
	# Make button Red
	var style_wrong = btn_node.get_theme_stylebox("pressed").duplicate()
	style_wrong.bg_color = Color(1.0, 0.3, 0.3) # Red
	style_wrong.border_color = Color(0.8, 0.2, 0.2)
	btn_node.add_theme_stylebox_override("disabled", style_wrong)
	btn_node.add_theme_color_override("font_disabled_color", Color.WHITE)
	
	lives -= 1
	update_lives()
	
	if lives <= 0:
		feedback_label.text = "[center][shake rate=20 level=10]YAH GAME OVER![/shake][/center]"
		await get_tree().create_timer(1.0).timeout
		game_over()
	else:
		feedback_label.text = "[center][shake rate=20 level=10]YAH SALAH TEBAK...[/shake][/center]"
		var tween = create_tween()
		tween.tween_property(btn_node, "position:x", btn_node.position.x + 15, 0.05)
		tween.tween_property(btn_node, "position:x", btn_node.position.x - 15, 0.05)
		tween.tween_property(btn_node, "position:x", btn_node.position.x, 0.05)
		
		await get_tree().create_timer(1.0).timeout
		feedback_label.text = ""
		# Enable buttons again
		for child in options_container.get_children():
			child.disabled = false

func game_over():
	final_score_label.text = "Nilai Akhir: " + str(score)
	game_over_overlay.visible = true
	GameManager.update_high_score(score)

func option_name_to_bbcode(color_name):
	return "[b]" + color_name + "[/b]"

func update_score():
	score_label.text = str(score)

func update_lives():
	var heart_str = ""
	for i in range(lives):
		heart_str += "❤️"
	lives_label.text = heart_str
