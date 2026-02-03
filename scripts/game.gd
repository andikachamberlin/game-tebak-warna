extends Control

@onready var color_display = $SafeArea/CardCenter/GameCard/Margin/Content/ColorDisplayContainer/Margin/ColorDisplay
@onready var options_container = $SafeArea/CardCenter/GameCard/Margin/Content/OptionsContainer
@onready var feedback_label = $SafeArea/CardCenter/GameCard/Margin/Content/FeedbackLabel
@onready var score_label = $SafeArea/TopBar/ScorePanel/Margin/ScoreLabel

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

func _ready():
	new_game()

func new_game():
	score = 0
	update_score()
	next_level()

func next_level():
	feedback_label.text = ""
	
	# Pick random color for question
	var available_colors = colors.duplicate()
	if current_question:
		available_colors.erase(current_question) # Avoid same color twice
	
	current_question = available_colors.pick_random()
	
	# Animate color change
	var tween = create_tween()
	tween.tween_property(color_display, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func(): 
		# Use StyleBoxFlat to set background color (Panel uses stylebox not just .color property directly often)
		# But since we use a Panel with StyleBoxFlat, we can modify the stylebox resource or just modulate self if it's white
		# For simplicity, let's assume the StyleBox is white and we modulate the panel
		color_display.modulate = current_question["color"]
	)
	tween.tween_property(color_display, "modulate:a", 1.0, 0.2)
	
	# Generate options (1 correct, 2 wrong)
	var options = [current_question]
	var wrong_options = colors.duplicate()
	wrong_options.erase(current_question)
	wrong_options.shuffle()
	
	options.append(wrong_options[0])
	options.append(wrong_options[1])
	options.shuffle()
	
	# Setup buttons
	for child in options_container.get_children():
		child.queue_free()
	
	for option in options:
		var btn = Button.new()
		btn.text = option["name"]
		
		# Tailwind-like Button Styles
		# System Font check? No easiest to just rely on styles
		btn.add_theme_font_size_override("font_size", 16)
		btn.custom_minimum_size = Vector2(0, 56)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		# Normal Style (bg-white border-slate-200 rounded-xl)
		var style_normal = StyleBoxFlat.new()
		style_normal.bg_color = Color.WHITE
		style_normal.set_border_width_all(1)
		style_normal.border_color = Color("e2e8f0") # slate-200
		style_normal.corner_radius_top_left = 12
		style_normal.corner_radius_top_right = 12
		style_normal.corner_radius_bottom_right = 12
		style_normal.corner_radius_bottom_left = 12
		style_normal.shadow_color = Color(0, 0, 0, 0.05)
		style_normal.shadow_size = 2
		style_normal.shadow_offset = Vector2(0, 1)
		
		# Hover Style (bg-slate-50 border-indigo-300 text-indigo-600)
		var style_hover = style_normal.duplicate()
		style_hover.bg_color = Color("f8fafc") # slate-50
		style_hover.border_color = Color("a5b4fc") # indigo-300
		style_hover.shadow_color = Color(0.31, 0.38, 0.97, 0.1) # indigo-500 alpha 0.1
		style_hover.shadow_size = 4
		style_hover.shadow_offset = Vector2(0, 2)
		
		# Pressed Style (bg-slate-100)
		var style_pressed = style_normal.duplicate()
		style_pressed.bg_color = Color("f1f5f9") # slate-100
		style_pressed.border_color = Color("cbd5e1") # slate-300
		style_pressed.shadow_size = 0
		
		btn.add_theme_stylebox_override("normal", style_normal)
		btn.add_theme_stylebox_override("hover", style_hover)
		btn.add_theme_stylebox_override("pressed", style_pressed)
		btn.add_theme_stylebox_override("focus", style_hover) # Focus same as hover
		
		# Text Colors
		btn.add_theme_color_override("font_color", Color("334155")) # slate-700
		btn.add_theme_color_override("font_hover_color", Color("4f46e5")) # indigo-600
		btn.add_theme_color_override("font_pressed_color", Color("4f46e5"))
		btn.add_theme_color_override("font_focus_color", Color("4f46e5"))
		
		btn.pressed.connect(_on_answer_selected.bind(btn, option))
		options_container.add_child(btn)

func _on_answer_selected(btn_node, option):
	# Disable all buttons to prevent spam
	for child in options_container.get_children():
		child.disabled = true
		
	if option == current_question:
		handle_correct(btn_node)
	else:
		handle_wrong(btn_node)

func handle_correct(btn_node):
	btn_node.modulate = Color.GREEN
	feedback_label.text = "BENAR! YEY!"
	feedback_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	
	score += 10
	update_score()
	
	var tween = create_tween()
	tween.tween_property(btn_node, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(btn_node, "scale", Vector2(1.0, 1.0), 0.1)
	
	await get_tree().create_timer(1.0).timeout
	next_level()

func handle_wrong(btn_node):
	btn_node.modulate = Color.RED
	feedback_label.text = "COBA LAGI YA..."
	feedback_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))
	
	var tween = create_tween()
	tween.tween_property(btn_node, "position:x", btn_node.position.x + 10, 0.05)
	tween.tween_property(btn_node, "position:x", btn_node.position.x - 10, 0.05)
	tween.tween_property(btn_node, "position:x", btn_node.position.x, 0.05)
	
	await get_tree().create_timer(1.0).timeout
	
	# Enable buttons again for retry
	for child in options_container.get_children():
		child.disabled = false
		child.modulate = Color.WHITE

func update_score():
	score_label.text = "Nilai: " + str(score)
