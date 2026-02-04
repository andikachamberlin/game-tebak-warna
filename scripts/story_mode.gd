extends Control

@onready var story_label = $SafeArea/VBox/DisplayContainer/VBoxContainer/StoryLabel
@onready var buttons_container = $SafeArea/VBox/DisplayContainer/VBoxContainer/ButtonsGrid
@onready var score_label = $SafeArea/VBox/Header/ScorePanel/ScoreLabel
@onready var feedback_label = $SafeArea/VBox/DisplayContainer/VBoxContainer/FeedbackLabel
@onready var lives_label = $SafeArea/VBox/Header/LivesPanel/Container/LivesLabel
@onready var game_over_panel = $GameOverPanel
@onready var pause_overlay = $PauseOverlay

# Resources
var font_resource = preload("res://assets/fonts/AmaticSC-Bold.ttf")

var score = 0
var lives = 3
var current_quest = {}
# Colors
var colors_easy = [
	{"name": "MERAH", "color": Color.RED, "hex": "RED"},
	{"name": "HIJAU", "color": Color.GREEN, "hex": "GREEN"},
	{"name": "BIRU", "color": Color.BLUE, "hex": "BLUE"},
	{"name": "KUNING", "color": Color(1, 0.8, 0), "hex": "YELLOW"}, # Gold-ish yellow
	{"name": "UNGU", "color": Color.PURPLE},
	{"name": "ORANYE", "color": Color("FF8000")},
	{"name": "HITAM", "color": Color.BLACK},
	{"name": "PUTIH", "color": Color.WHITE},
	{"name": "COKLAT", "color": Color.BROWN},
	{"name": "MERAH MUDA", "color": Color("FFC0CB")}, # Pink
	{"name": "BIRU MUDA", "color": Color("00FFFF")}, # Cyan
	{"name": "HIJAU LAUT", "color": Color("20B2AA")} # Light Sea Green
]

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
	{"name": "NILA", "color": Color.INDIGO},
	{"name": "HIJAU LIMAU", "color": Color("32CD32")},
	{"name": "ZAITUN", "color": Color("808000")},
	{"name": "BIRU DONGKER", "color": Color("000080")},
	{"name": "MERAH ATI", "color": Color("800000")},
	{"name": "HIJAU TOSCA", "color": Color("40E0D0")},
	{"name": "KORAL", "color": Color("FF7F50")},
	{"name": "EMAS", "color": Color("FFD700")},
	{"name": "SALEM", "color": Color("FA8072")},
	{"name": "KAKI", "color": Color("F0E68C")},
	{"name": "LAVENDER", "color": Color("E6E6FA")},
	{"name": "KREM", "color": Color("F5F5DC")},
	{"name": "MINT", "color": Color("98FF98")}
]

# Quest templates
var templates = [
	# --- FANTASY & MAGIC ---
	{"text": "Monster ini alergi warna {color}!\nJangan beri dia warna itu!", "type": "AVOID"},
	{"text": "Raja ingin jubah warna {color}!\nCari warnanya!", "type": "PICK"},
	{"text": "Kumpulkan kristal {color} untuk tongkat penyihir!", "type": "PICK"},
	{"text": "Ramuan ini butuh ekstrak bunga {color}!\nPetik bunganya!", "type": "PICK"},
	{"text": "Naga itu hanya menyemburkan api {color}!\nHindari apinya!", "type": "AVOID"},
	{"text": "Peri hutan bersembunyi di balik daun {color}.\nTemukan dia!", "type": "PICK"},
	{"text": "Buku mantra kuno bersampul {color} hilang!\nBantu penyihir menemukannya!", "type": "PICK"},
	{"text": "Pedang legendaris bersinar {color}.\nYang mana pedangnya?", "type": "PICK"},
	{"text": "Jangan minum ramuan yang berwarna {color}!\nItu racun tidur!", "type": "AVOID"},

	# --- ADVENTURE & HAZARD ---
	{"text": "Jangan injak rumput yang warnanya {color}!", "type": "AVOID"},
	{"text": "Awas! Lantai {color} itu lava panas!\nPilih yang aman!", "type": "AVOID"},
	{"text": "Hati-hati! Laser {color} beracun!\nJangan disentuh!", "type": "AVOID"},
	{"text": "Pintu ini hanya terbuka dengan kunci {color}!", "type": "PICK"},
	{"text": "Jembatan warna {color} sudah rapuh!\nJangan lewat situ!", "type": "AVOID"},
	{"text": "Pilih jalur yang TIDAK berwarna {color} untuk selamat!", "type": "AVOID"},
	{"text": "Ada ranjau darat di kotak {color}!\nHati-hati!", "type": "AVOID"},
	{"text": "Tekan tombol darurat warna {color} sekarang!", "type": "PICK"},

	# --- SCI-FI & SPACE ---
	{"text": "Alien dari planet {color} mendarat!\nSambut mereka!", "type": "PICK"},
	{"text": "Pesawat musuh menembakkan sinar {color}!\nHindari tembakannya!", "type": "AVOID"},
	{"text": "Isi bahan bakar roket dengan cairan {color}!", "type": "PICK"},
	{"text": "Robot ini rusak kalau kena kabel {color}!\nJangan potong kabel itu!", "type": "AVOID"},
	{"text": "Sinyal SOS datang dari bintang {color}!\nLacak sinyalnya!", "type": "PICK"},
	{"text": "Oksigen tinggal di tabung {color}!\nCepat ambil!", "type": "PICK"},

	# --- DAILY LIFE & FUN ---
	{"text": "Mobil balap ini warnanya {color}!\nYang mana mobilnya?", "type": "PICK"},
	{"text": "Adik minta balon warna {color}!\nAmbilkan dong!", "type": "PICK"},
	{"text": "Jangan makan permen warna {color}!\nItu rasa pedas!", "type": "AVOID"},
	{"text": "Lampu lalu lintas menyala {color}!\nIkuti aturannya!", "type": "PICK"},
	{"text": "Kucingku hilang! Dia pakai kalung {color}!", "type": "PICK"},
	{"text": "Lukisan ini jelek kalau ada warna {color}.\nHindari warnanya!", "type": "AVOID"},
	{"text": "Ibu minta tolong belikan benang {color}.", "type": "PICK"},
	{"text": "Payung {color} sudah bolong.\nPakai yang lain!", "type": "AVOID"},
	{"text": "Cari koper warna {color} di bagasi!", "type": "PICK"},
	{"text": "Topi warna {color} sedang diskon!\nBeli yang itu!", "type": "PICK"},

	# --- FOOD & COOKING ---
	{"text": "Koki butuh bumbu warna {color}!", "type": "PICK"},
	{"text": "Jangan masak jamur yang berwarna {color}!\nItu beracun!", "type": "AVOID"},
	{"text": "Hias kue ulang tahun dengan krim {color}!", "type": "PICK"},
	{"text": " Jus {color} ini sudah basi.\nBuang saja!", "type": "PICK"}, # Valid logic: Pick the bad one to throw away? Or Avoid drinking? Context means "Find the bad one". So PICK.
	{"text": "Pelanggan pesan es krim rasa {color}!", "type": "PICK"}
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
	
	# Determine color pool based on score/progression
	var current_level_colors = []
	if score < 10:
		current_level_colors = colors_easy.slice(0, 4) # R, B, G, Y
	elif score < 20:
		current_level_colors = colors_easy.slice(0, 10) # + Purple, Orange, Black, White, Brown
	elif score < 30:
		current_level_colors = colors_easy # All Easy
	else:
		current_level_colors = colors_easy + colors_hard
	
	var template = templates.pick_random()
	var target_color_data = current_level_colors.pick_random()
	
	current_quest = {
		"type": template["type"],
		"target": target_color_data,
		"text": template["text"].format({"color": target_color_data["name"]})
	}
	
	story_label.text = current_quest["text"]
	setup_buttons(current_level_colors)

func setup_buttons(level_colors):
	for child in buttons_container.get_children():
		child.queue_free()
	
	# We need some distractor colors + correct/target colors.
	# For simplicity, let's just show a subset of current_level_colors or all of them shuffled.
	# If the pool is huge (hard mode), maybe pick random 12?
	
	var shuffled_colors = level_colors.duplicate()
	shuffled_colors.shuffle()
	
	# Limit buttons if too many
	if shuffled_colors.size() > 12:
		# Ensure target is in
		var temp_colors = []
		# If TYPE is PICK, target MUST be there.
		if current_quest["type"] == "PICK":
			temp_colors.append(current_quest["target"])
			
		# Fill rest
		for c in shuffled_colors:
			if c["name"] != current_quest["target"]["name"] and temp_colors.size() < 12:
				temp_colors.append(c)
		
		temp_colors.shuffle()
		shuffled_colors = temp_colors
	
	buttons_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	for color_data in shuffled_colors:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(250, 150)
		btn.pivot_offset = Vector2(125, 75) # Half of size
		btn.scale = Vector2.ZERO
		
		var style = StyleBoxFlat.new()
		style.bg_color = color_data["color"]
		style.set_corner_radius_all(20)
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
	AudioManager.play_success()
	feedback_label.text = "BENAR!"
	feedback_label.modulate = Color.GREEN
	update_score(score + 1)
	
	var tween = create_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(next_level)

func handle_wrong():
	AudioManager.play_failed()
	feedback_label.text = "SALAH!"
	feedback_label.modulate = Color.RED
	lives -= 1
	update_lives_ui()
	
	if lives <= 0:
		game_over()
	else:
		# Maybe a short delay or shuffle? Let's just create new quest
		var tween = create_tween()
		tween.tween_interval(0.5)
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
	$GameOverPanel/CenterContainer/Card/Margin/VBox/FinalScoreLabel.text = "Skor: " + str(score)
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
