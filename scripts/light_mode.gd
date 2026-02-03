extends Control

@onready var object_rect = $CenterContainer/VBoxContainer/ObjectContainer/ObjectRect
@onready var light_overlay = $CenterContainer/VBoxContainer/ObjectContainer/LightOverlay
@onready var prompt_label = $CenterContainer/VBoxContainer/PromptLabel
@onready var condition_label = $CenterContainer/VBoxContainer/ConditionLabel
@onready var buttons_container = $CenterContainer/VBoxContainer/ButtonsGrid
@onready var feedback_label = $CenterContainer/VBoxContainer/FeedbackLabel
@onready var score_label = $HUD/ScoreLabel
@onready var game_over_panel = $GameOverPanel

var score = 0
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
		"tint": Color(0.2, 0.2, 0.5, 1.0), # Dark Blue tint simulating night
		"desc": "Benda ini ada di keheningan malam..."
	},
	{
		"name": "Ruang Gelap",
		"tint": Color(0.15, 0.15, 0.15, 1.0), # Just dark
		"desc": "Lampu padam! Benda apa ini?"
	},
	{
		"name": "Senja",
		"tint": Color(0.8, 0.5, 0.3, 1.0), # Orange tint
		"desc": "Matahari terbenam menyinari benda ini..."
	},
	{
		"name": "Bawah Pohon Rindang",
		"tint": Color(0.1, 0.3, 0.1, 1.0), # Dark Greenish shadow
		"desc": "Tertutup bayangan daun pohon..."
	},
	{
		"name": "Lampu Disko Ungu",
		"tint": Color(0.6, 0.0, 0.8, 1.0), # Extreme Purple light
		"desc": "Kena sorot lampu panggung..."
	}
]

func _ready():
	randomize()
	game_over_panel.hide()
	update_score(0)
	next_level()

func next_level():
	feedback_label.text = ""
	
	# Pick random object color
	var object_data = colors.pick_random()
	
	# Pick random lighting condition
	var condition = conditions.pick_random()
	
	current_round = {
		"object": object_data,
		"condition": condition
	}
	
	# display
	object_rect.color = object_data["color"]
	# Apply lighting: We use a separate overlay rect with 'multiply' blend mode or just modulate parent.
	# Simpler: Modulate the ObjectRect directly?
	# Real world: Object Color * Light Color.
	object_rect.modulate = condition["tint"]
	
	condition_label.text = condition["desc"] + "\n(" + condition["name"] + ")"
	
	setup_buttons()

func setup_buttons():
	for child in buttons_container.get_children():
		child.queue_free()
	
	var answers = colors.duplicate()
	answers.shuffle()
	
	for color_data in answers:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(250, 100)
		
		# For buttons, we show the "True" colors so user can pick the concept
		var style = StyleBoxFlat.new()
		style.bg_color = color_data["color"]
		style.set_corner_radius_all(15)
		# Add border to make White visible
		style.border_width_bottom = 5
		style.border_color = Color.BLACK
		
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		
		# Add text because colors might be confusing under logic if buttons were also lit (they are not)
		btn.text = color_data["name"]
		# Text color contrast
		if color_data["color"].get_luminance() > 0.5:
			btn.add_theme_color_override("font_color", Color.BLACK)
		else:
			btn.add_theme_color_override("font_color", Color.WHITE)
			
		btn.pressed.connect(_on_answer_selected.bind(color_data))
		buttons_container.add_child(btn)

func _on_answer_selected(selected_color):
	if selected_color["name"] == current_round["object"]["name"]:
		handle_correct()
	else:
		handle_wrong()

func handle_correct():
	feedback_label.text = "HEBAT! Mata yang tajam!"
	feedback_label.modulate = Color.GREEN
	
	# Reveal true color by resetting modulate temporarily
	var tween = create_tween()
	tween.tween_property(object_rect, "modulate", Color.WHITE, 0.5)
	
	update_score(score + 1)
	
	tween.tween_interval(1.0)
	tween.tween_callback(next_level)

func handle_wrong():
	feedback_label.text = "Salah... Itu tadi " + current_round["object"]["name"]
	feedback_label.modulate = Color.RED
	
	# Reveal to show why
	var tween = create_tween()
	tween.tween_property(object_rect, "modulate", Color.WHITE, 0.5)
	
	game_over()

func update_score(val):
	score = val
	score_label.text = str(score)

func game_over():
	game_over_panel.show()
	$GameOverPanel/VBoxContainer/FinalScoreLabel.text = "Skor: " + str(score)

func _on_restart_button_pressed():
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
