extends Node

var bgm_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []

var button_sfx = preload("res://assets/sfx/button.mp3")

func play_button_click():
	play_sfx(button_sfx, 0.0, 1.0)

func play_button_hover():
	# Rekomendasi: Pitch sedikit lebih tinggi dan volume lebih kecil untuk hover
	play_sfx(button_sfx, -5.0, 1.2)

func _ready():
	# Setup BGM Player
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Music" # Assumes "Music" bus exists, or defaults to Master if not found ideally
	add_child(bgm_player)
	
	# Setup SFX Players Pool
	for i in range(10):
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		sfx_players.append(p)
		
	# Ensure Buses exist (Fallback to Master if not)
	if AudioServer.get_bus_index("Music") == -1:
		bgm_player.bus = "Master"
	if AudioServer.get_bus_index("SFX") == -1:
		for p in sfx_players:
			p.bus = "Master"

func play_music(stream: AudioStream, volume_db: float = 0.0):
	if bgm_player.stream == stream and bgm_player.playing:
		return
		
	bgm_player.stream = stream
	
	# Try enabling loop relative to stream type
	if "loop" in stream:
		stream.loop = true
		
	bgm_player.volume_db = volume_db
	bgm_player.play()

func stop_music():
	bgm_player.stop()

func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0):
	for p in sfx_players:
		if not p.playing:
			p.stream = stream
			p.volume_db = volume_db
			p.pitch_scale = pitch_scale
			p.play()
			return
	
	# If all busy, force use the first one (or create new, but pool is usually enough)
	sfx_players[0].stream = stream
	sfx_players[0].volume_db = volume_db
	sfx_players[0].pitch_scale = pitch_scale
	sfx_players[0].play()
