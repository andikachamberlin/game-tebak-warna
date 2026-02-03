extends Node2D

@onready var player = $Player
@onready var platforms_container = $Platforms
@onready var hud_label = $CanvasLayer/HUD/TargetLabel
@onready var score_label = $CanvasLayer/HUD/ScoreLabel
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
var is_game_over = false

func _ready():
	randomize()
	spawn_initial_platforms()
	set_new_target()
	player.connect("landed", _on_player_landed)
	game_over_panel.hide()

func _process(_delta):
	if is_game_over: return
	
	# Spawn more platforms as player goes up
	if player.position.y < last_platform_y + 1000:
		spawn_platform(last_platform_y - platform_spacing)
	
	# Check falling (Death)
	if player.position.y > last_platform_y + 2000: # Simple check if fallen too far below "last" (which is actually highest/lowest Y)
		# Wait, last_platform_y goes negative (up).
		# We need to track the lowest platform or camera view.
		# Simplest: if player.y > (camera_center + 1000) -> Die.
		pass
	
	if player.position.y > 600: # Falling below start
		game_over()

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
	hud_label.text = "LOMPAT KE: " + target_color_data["name"]
	hud_label.modulate = target_color_data["color"] # Or keep white text?
	# Make text color different for extra challenge (Stroop)
	# But user said "Tebak Warna + Gerakan".
	# Let's keep text color matching for now to be "fairer" platformer, or random.
	hud_label.modulate = Color.WHITE

func _on_player_landed(platform):
	if is_game_over: return
	
	if platform.color_data.get("name") == "START":
		return
		
	if platform.color_data["name"] == target_color_data["name"]:
		score += 1
		score_label.text = str(score)
		platform.queue_free() # Make it disappear? Or just jump off?
		# User: "Lompat ke platform warna yang sesuai"
		# If we keep it, player can rest.
		# Let's just update target
		set_new_target()
		
		# Optional: Bounce effect
		player.velocity.y = -600
	else:
		# Wrong color
		game_over()

func game_over():
	is_game_over = true
	game_over_panel.show()
	$CanvasLayer/GameOverPanel/VBoxContainer/FinalScoreLabel.text = "Skor: " + str(score)
	GameManager.update_high_score(score)

func _on_restart_button_pressed():
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
