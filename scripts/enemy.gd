extends CharacterBody2D

var speed = 50  # Reduced for better gameplay feel
var player_chase = false
var player = null
var health = 80
var player_inattack_zone = false
var can_take_damage = true

# Navigation variables
var path = []
var path_index = 0
var target_position = Vector2.ZERO
var direction = Vector2.ZERO

func _ready():
	# Ensure the animated sprite starts in idle state
	$AnimatedSprite2D.play("walk")

func _physics_process(delta):
	deal_with_damage()
	
	if player_chase and player != null:
		# Calculate direction to player
		direction = (player.position - position).normalized()
		
		# Set velocity based on direction and speed
		velocity = direction * speed
		
		# Apply movement using move_and_slide()
		move_and_slide()
		
		# Update animation based on movement
		update_animation()
	else:
		# If not chasing, stop moving
		velocity = Vector2.ZERO
		$AnimatedSprite2D.play("walk")  # Or an idle animation if available

func update_animation():
	$AnimatedSprite2D.play("walk")
	
	# Flip sprite based on horizontal movement
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity.x > 0:
		$AnimatedSprite2D.flip_h = false

func _on_detection_area_body_entered(body):
	# Check if the detected body is the player
	if body.has_method("player"):
		player = body
		player_chase = true

func _on_detection_area_body_exited(body):
	# Check if the exiting body is the player
	if body.has_method("player"):
		player = null
		player_chase = false

func enemy():
	pass

func _on_enemy_hitbox_body_entered(body):
	if body.has_method("player"):
		player_inattack_zone = true

func _on_enemy_hitbox_body_exited(body):
	if body.has_method("player"):
		player_inattack_zone = false

func deal_with_damage():
	# Check if player is attacking and we're in the attack zone
	if player_inattack_zone and Global.player_current_attack == true:
		if can_take_damage == true:
			health = health - 20
			$take_damage_cooldown.start()
			can_take_damage = false
			print("slime health = ", health)
			
			# Create a knockback effect when taking damage
			if player != null:
				# Get knockback direction (away from player)
				var knockback_direction = (position - player.position).normalized()
				velocity = knockback_direction * (speed * 3)  # Knockback with 3x speed
				
				# Apply the knockback (will be overridden in next _physics_process)
				move_and_slide()
			
			# If enemy health reaches zero or less, destroy the enemy
			if health <= 0:
				self.queue_free()

func _on_take_damage_cooldown_timeout():
	can_take_damage = true
