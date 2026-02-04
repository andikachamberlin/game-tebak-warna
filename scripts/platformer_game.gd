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


var platform_scene = preload("res://scenes/platform.tscn")

var last_platform_y = 0
var platform_spacing = 150
var colors = [
	{"name": "MERAH", "color": Color.RED},
	{"name": "HIJAU", "color": Color.GREEN},
	{"name": "BIRU", "color": Color.BLUE},
	{"name": "KUNING", "color": Color.YELLOW}
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

func _process(_delta):
	if is_game_over: return
	
	# Spawn more platforms as player goes up
	if player.position.y < last_platform_y + 1000:
		spawn_platform(last_platform_y - platform_spacing)
	
	if player.position.y > 600: # Falling below start
		handle_death()

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
		
	if platform.color_data["name"] == target_color_data["name"]:
		score += 1
		score_label.text = str(score)
		platform.queue_free() # Disappear
		AudioManager.play_success()
		set_new_target()
		
		# Bounce effect
		player.velocity.y = -600
	else:
		# Wrong color
		AudioManager.play_failed()
		lives -= 1
		update_lives()
		if lives <= 0:
			game_over()
		else:
			# Just bounce a bit or punish?
			platform.queue_free() # Make it disappear so they fall?
			# Or just warn
			pass

func handle_death():
	lives -= 1
	update_lives()
	if lives <= 0:
		game_over()
	else:
		# Respawn? Or just reset position?
		# Platformer usually reset position or checkpoint.
		# For endless jumper, falling is usually fatal.
		# Let's make falling fatal game over regardless of lives for now, or use lives for "Wrong Colors" only.
		game_over()

func update_lives():
	var hearts = ""
	for i in range(lives):
		hearts += "❤️"
	lives_label.text = hearts

func game_over():
	is_game_over = true
	game_over_panel.show()
	$CanvasLayer/GameOverPanel/Margin/VBoxContainer/FinalScoreLabel.text = "Skor: " + str(score)
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
