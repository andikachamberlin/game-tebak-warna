extends Control

@onready var animation_player = $AnimationPlayer

var target_scene = "res://scenes/main_menu.tscn"

func _ready():
	# Simulate loading time
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file(target_scene)
