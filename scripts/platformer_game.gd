extends Node2D

@onready var player = $Player
@onready var platforms_container = $Platforms
@onready var hud_label = $CanvasLayer/HUD/TargetLabel
@onready var score_label = $CanvasLayer/HUD/ScoreLabel
@onready var lives_label = $CanvasLayer/HUD/LivesLabel
@onready var pause_overlay = $CanvasLayer/PauseOverlay
@onready var pause_button = $CanvasLayer/HUD/PauseButton
# Labels for translation
@onready var target_label = $CanvasLayer/HUD/TargetLabel
@onready var pause_label = $CanvasLayer/PauseOverlay/CenterContainer/Card/Margin/VBox/Label
@onready var resume_button = $CanvasLayer/PauseOverlay/CenterContainer/Card/Margin/VBox/ResumeButton
@onready var menu_button = $CanvasLayer/PauseOverlay/CenterContainer/Card/Margin/VBox/MenuButton
@onready var game_over_panel = $CanvasLayer/GameOverPanel

# Resources
var font_resource = preload("res://assets/fonts/AmaticSC-Bold.ttf")


var platform_scene = preload("res://scenes/platform.tscn")

var last_platform_y = 0
var platform_spacing = 150
var colors = [
	{"name": "MERAH", "color": Color.RED},
	{"name": "HIJAU", "color": Color.GREEN},
	{"name": "BIRU", "color": Color.BLUE},
	{"name": "KUNING", "color": Color.YELLOW},
	{"name": "MERAH MUDA", "color": Color("FFC0CB")},
	{"name": "BIRU MUDA", "color": Color("00FFFF")},
	{"name": "UNGU", "color": Color.PURPLE},
	{"name": "ORANYE", "color": Color("FF8000")},
	{"name": "COKLAT", "color": Color.BROWN}
]

var target_color_data = {}
var score = 0
var lives = 3
var is_game_over = false

func _ready():
	randomize()
	spawn_initial_platforms()
	set_new_target()
	update_lives()
	
	player.connect("landed", _on_player_landed)
	game_over_panel.hide()
	pause_overlay.hide()
	
	# Polish Pause Menu Buttons with Hover Effects
	# Resume Button (Green)
	var style_green = StyleBoxFlat.new()
	style_green.bg_color = Color("4CAF50")
	style_green.set_corner_radius_all(20)
	style_green.shadow_size = 5
	style_green.shadow_offset = Vector2(0, 4)
	style_green.shadow_color = Color(0, 0, 0, 0.2)
	
	var style_green_hover = style_green.duplicate()
	style_green_hover.bg_color = Color("45a049")
	style_green_hover.shadow_size = 8
	style_green_hover.shadow_offset = Vector2(0, 6)
	
	var style_green_pressed = style_green.duplicate()
	style_green_pressed.bg_color = Color("3d8b40")
	style_green_pressed.shadow_size = 2
	style_green_pressed.shadow_offset = Vector2(0, 2)
	
	resume_button.add_theme_stylebox_override("normal", style_green)
	resume_button.add_theme_stylebox_override("hover", style_green_hover)
	resume_button.add_theme_stylebox_override("pressed", style_green_pressed)
	resume_button.add_theme_font_override("font", font_resource)
	resume_button.add_theme_color_override("font_color", Color.WHITE)
	resume_button.add_theme_color_override("font_hover_color", Color(0.95, 1, 0.95))
	resume_button.add_theme_color_override("font_pressed_color", Color(0.9, 0.9, 0.9))
	
	# Menu Button (Red/Orange)
	var style_red = StyleBoxFlat.new()
	style_red.bg_color = Color("FF7043")
	style_red.set_corner_radius_all(20)
	style_red.shadow_size = 5
	style_red.shadow_offset = Vector2(0, 4)
	style_red.shadow_color = Color(0, 0, 0, 0.2)
	
	var style_red_hover = style_red.duplicate()
	style_red_hover.bg_color = Color("F4511E")
	style_red_hover.shadow_size = 8
	style_red_hover.shadow_offset = Vector2(0, 6)
	
	var style_red_pressed = style_red.duplicate()
	style_red_pressed.bg_color = Color("E64A19")
	style_red_pressed.shadow_size = 2
	style_red_pressed.shadow_offset = Vector2(0, 2)
	
	menu_button.add_theme_stylebox_override("normal", style_red)
	menu_button.add_theme_stylebox_override("hover", style_red_hover)
	menu_button.add_theme_stylebox_override("pressed", style_red_pressed)
	menu_button.add_theme_font_override("font", font_resource)
	menu_button.add_theme_color_override("font_color", Color.WHITE)
	menu_button.add_theme_color_override("font_hover_color", Color(1, 0.95, 0.95))
	menu_button.add_theme_color_override("font_pressed_color", Color(0.9, 0.9, 0.9))

func _process(_delta):
	if is_game_over: return
	
	# Spawn more platforms as player goes up
	if player.position.y < last_platform_y + 1000:
		spawn_platform(last_platform_y - platform_spacing)
	
	# Keep the "Floor" at the bottom of the screen
	# If player goes up, the barrier follows but stays at a distance
	var barrier_y = player.position.y + 600
	if $DeathBarrier.position.y > barrier_y: # Only move it up, don't let it fall back
		$DeathBarrier.position.y = barrier_y
	elif $DeathBarrier.position.y < barrier_y - 200: # Keep it close enough if player falls
		$DeathBarrier.position.y = barrier_y - 200

func spawn_initial_platforms():
	# Ground platform
	var p = platform_scene.instantiate()
	p.position = Vector2(0, 100)
	p.scale.x = 10 # Make it wide
	p.setup({"name": "START", "color": Color.GRAY})
	platforms_container.add_child(p)
	
	# Initial set
	for i in range(10):
		spawn_platform(last_platform_y - platform_spacing)

func spawn_platform(y_pos):
	var p = platform_scene.instantiate()
	var x_pos = randf_range(-150, 150)
	var rand_color = colors.pick_random()
	
	p.position = Vector2(x_pos, y_pos)
	p.setup(rand_color)
	platforms_container.add_child(p)
	
	last_platform_y = y_pos

func set_new_target():
	target_color_data = colors.pick_random()
	hud_label.text = "LOMPAT KE: " + target_color_data["name"] # Should translate "LOMPAT KE" too if needed
	hud_label.modulate = Color.WHITE

func _on_player_landed(platform):
	if is_game_over: return
	
	if platform.color_data.get("name") == "START":
		return
		
	# Always remove touched platforms after landing to keep the game moving
	platform.queue_free()
	
	if platform.color_data["name"] == target_color_data["name"]:
		score += 1
		score_label.text = str(score)
		AudioManager.play_success()
		set_new_target()
		
		# BIG Bounce (Boost)
		player.velocity.y = -1000
		
		# Visual feedback on Target Label
		var tween = create_tween()
		tween.tween_property(hud_label, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(hud_label, "scale", Vector2(1.0, 1.0), 0.1)
	else:
		# Wrong color: Lose a life!
		AudioManager.play_failed()
		lives -= 1
		update_lives()
		
		if lives <= 0:
			game_over()
		else:
			# Small bounce to give player chance to recover
			player.velocity.y = -600

func handle_death():
	AudioManager.play_failed()
	lives -= 1
	update_lives()
	
	if lives <= 0:
		game_over()
	else:
		# Respawn: Put a new start platform under the player
		var p = platform_scene.instantiate()
		p.position = Vector2(player.position.x, player.position.y + 100)
		p.scale.x = 10
		p.setup({"name": "START", "color": Color.GRAY})
		platforms_container.add_child(p)
		
		# Small invulnerability or just stop falling
		player.velocity = Vector2.ZERO

func update_lives():
	var hearts = ""
	for i in range(lives):
		hearts += "❤️"
	lives_label.text = hearts

func game_over():
	is_game_over = true
	game_over_panel.show()
	
	var vbox = $CanvasLayer/GameOverPanel/Margin/VBoxContainer
	
	# Clear existing children to rebuild UI cleanly
	for child in vbox.get_children():
		child.queue_free()
		
	# 1. Title Label
	var title = Label.new()
	title.text = "PETUALANGAN SELESAI"
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
