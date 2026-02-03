extends StaticBody2D

@onready var color_rect = $ColorRect
@onready var label = $Label

var color_data = {}

func _ready():
	if color_data:
		$ColorRect.color = color_data["color"]

func setup(data):
	color_data = data
	if is_inside_tree():
		$ColorRect.color = data["color"]

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		# Notify game that player touched this platform
		# This requires the game to listen or the platform to call up
		# Simpler: The Game script manages the state, Player collision logic checks "is_on_floor" and what collider it is.
		pass
