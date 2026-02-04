extends CharacterBody2D

const SPEED = 500.0
const JUMP_VELOCITY = -1000.0
const GRAVITY = 1500.0

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle Jump with bouncy animation
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY
		
		# Squash & Stretch animation for bouncy feel
		var tween = create_tween()
		tween.set_parallel(true)
		
		# Squash down before jump (wide and short)
		tween.tween_property(self, "scale", Vector2(1.3, 0.7), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
		# Then stretch up (tall and narrow)
		tween.chain().tween_property(self, "scale", Vector2(0.8, 1.2), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
		# Return to normal
		tween.chain().tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Prevent player from going below the floor (stricter clamp)
	if position.y > 650:
		position.y = 650
		velocity.y = min(velocity.y, 0) # Don't allow downward movement
	
	move_and_slide()
	
	# Clamp horizontal position to camera boundaries
	# Camera limits: left=-700, right=700, viewport width ~1080, so visible range is ~540px each side
	position.x = clamp(position.x, -450, 450)
	
	# Double-check vertical position after physics movement
	if position.y > 650:
		position.y = 650
		velocity.y = 0
	
	# Check for collisions
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("platforms"):
			# Only trigger if landing on top (normal roughly up)
			if collision.get_normal().y < -0.5:
				emit_signal("landed", collider)

signal landed(platform)
