extends Control

@onready var animation_player = $AnimationPlayer
@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var percent_label = $VBoxContainer/PercentLabel

var progress = 0.0
var target_scene = "res://scenes/main_menu.tscn"
var loading = false

func _ready():
	# Start animation
	animation_player.play("fade_in")
	loading = true
	# Simulate loading process
	start_loading()

func start_loading():
	var tween = create_tween()
	# Fast to 30%
	tween.tween_property(self, "progress", 30.0, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Slow to 70%
	tween.tween_property(self, "progress", 70.0, 1.5).set_trans(Tween.TRANS_LINEAR)
	# Fast to 100%
	tween.tween_property(self, "progress", 100.0, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	tween.finished.connect(_on_loading_finished)

func _process(delta):
	if loading:
		progress_bar.value = progress
		percent_label.text = str(int(progress)) + "%"

func _on_loading_finished():
	loading = false
	# Wait a bit before switching
	await get_tree().create_timer(0.5).timeout
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(target_scene)
