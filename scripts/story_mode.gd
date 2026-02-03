extends Control

@onready var story_label = $CenterContainer/VBoxContainer/StoryLabel
@onready var buttons_container = $CenterContainer/VBoxContainer/ButtonsGrid
@onready var score_label = $HUD/ScoreLabel
@onready var feedback_label = $CenterContainer/VBoxContainer/FeedbackLabel
@onready var game_over_panel = $GameOverPanel

# Resources
var font_resource = preload("res://assets/fonts/AmaticSC-Bold.ttf")

var score = 0
var current_quest = {}
var colors = [
	{"name": "MERAH", "color": Color.RED, "hex": "RED"},
	{"name": "HIJAU", "color": Color.GREEN, "hex": "GREEN"},
	{"name": "BIRU", "color": Color.BLUE, "hex": "BLUE"},
	{"name": "KUNING", "color": Color(1, 0.8, 0), "hex": "YELLOW"} # Gold-ish yellow
]

# Quest templates
# Type: "PICK" (Choose the Target color), "AVOID" (Choose any BUT Target color)
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
	update_score(0)
	next_level()

func next_level():
	feedback_label.text = ""
	
	# Generate Quest
	var template = templates.pick_random()
	var target_color_data = colors.pick_random()
	
	current_quest = {
		"type": template["type"],
		"target": target_color_data,
		"text": template["text"].format({"color": target_color_data["name"]})
	}
	
	story_label.text = current_quest["text"]
	# Colorize the color name in the text for emphasis? 
	# For simplicity, we assume the text is clear. 
	# Optionally use RichTextLabel but Label is easier for now.
	
	setup_buttons()

func setup_buttons():
	# Clear existing buttons
	for child in buttons_container.get_children():
		child.queue_free()
	
	# Create 4 buttons with random colors from our list
	# To make "AVOID" tricky, we must include the target color.
	# To make "PICK" possible, we must include the target color.
	
	# Shuffle colors
	var shuffled_colors = colors.duplicate()
	shuffled_colors.shuffle()
	
	for color_data in shuffled_colors:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(250, 150)
		
		# Style
		var style = StyleBoxFlat.new()
		style.bg_color = color_data["color"]
		style.set_corner_radius_all(20)
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		
		# Optional: Add text or keep it plain blocks of color?
		# "Tebak Warna" -> usually blocks of color.
		
		btn.pressed.connect(_on_color_selected.bind(color_data))
		buttons_container.add_child(btn)

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
	feedback_label.text = "BENAR!"
	feedback_label.modulate = Color.GREEN
	update_score(score + 1)
	
	# Slight delay before next level
	var tween = create_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(next_level)

func handle_wrong():
	feedback_label.text = "SALAH!"
	feedback_label.modulate = Color.RED
	game_over()

func update_score(val):
	score = val
	score_label.text = str(score)

func game_over():
	game_over_panel.show()
	$GameOverPanel/VBoxContainer/FinalScoreLabel.text = "Skor: " + str(score)
	GameManager.update_high_score(score)

func _on_restart_button_pressed():
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
