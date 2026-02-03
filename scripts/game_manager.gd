extends Node

const SAVE_PATH = "user://savegame.save"

var high_score = 0

func _ready():
	load_game()

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(high_score)

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		high_score = file.get_32()

func update_high_score(new_score):
	if new_score > high_score:
		high_score = new_score
		save_game()
		return true
	return false
