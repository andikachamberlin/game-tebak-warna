extends Node3D

@onready var mesh_instance = $MeshInstance3D

var target_scale = Vector3.ONE
var idle_time = 0.0

func _ready():
	# Ensure material serves purely for this instance
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.WHITE
	mat.roughness = 0.2
	mat.metallic = 0.1
	mesh_instance.material_override = mat

func _process(delta):
	idle_time += delta * 2.0
	
	# Idle "Breathing" and "Looking around" rotation
	var rotation_x = sin(idle_time * 0.5) * 0.1
	var rotation_y = cos(idle_time * 0.3) * 0.15
	var rotation_z = sin(idle_time * 0.7) * 0.05
	
	mesh_instance.rotation = Vector3(rotation_x, rotation_y, rotation_z)
	
	# Slight floating bounce
	mesh_instance.position.y = sin(idle_time) * 0.1

func set_color(color: Color):
	if mesh_instance.material_override:
		mesh_instance.material_override.albedo_color = color

func jelly_bounce():
	var tween = create_tween()
	# Squash
	tween.tween_property(mesh_instance, "scale", Vector3(1.3, 0.7, 1.3), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	# Stretch/Pop
	tween.tween_property(mesh_instance, "scale", Vector3(0.8, 1.2, 0.8), 0.15)
	# Return to normal
	tween.tween_property(mesh_instance, "scale", Vector3(1.0, 1.0, 1.0), 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
