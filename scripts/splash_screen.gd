extends Control

@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("fade_in")
	await get_tree().create_timer(2.5).timeout
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://scenes/loading_screen.tscn")
