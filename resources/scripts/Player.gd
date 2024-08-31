extends CharacterBody2D
class_name Player

@export var speed = 500
@export var jump_force = 20000
@export var max_jumps = 2
@export var walljump_force = 20000
@export var dash_power = 30000
@export var max_health = 3
@export var weapon_orbit_radius: float = 15.0

var current_weapon = "Shotgun"
var current_speed = 0.0
var jumps = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health = max_health:
	set(value):
		health = value
		World.instance.update_health()

func _process(delta):
	if not is_on_floor():
		velocity.y += gravity*delta
	else:
		jumps = 0
	if health > 0:
		if Input.is_action_just_pressed("jump"):
			# the position checks are just so we dont
			# walljump on the platforms
			if not is_on_floor() and is_on_wall() and (position.x >= 0 and position.x <= 60 and $AnimatedSprite2D.flip_h == false) or (position.x >= 460 and $AnimatedSprite2D.flip_h == true) and round(velocity.y) != 0:
				# walljump
				velocity.x -= (float(round(current_speed/200))/10+1)*(walljump_force*(1 if $AnimatedSprite2D.flip_h else -1)*delta)
				jumps -= 1 # allow the player to jump
			if jumps < max_jumps:
				var jmp = 1
				if jumps == 1:
					jmp = 1.5
				velocity.y -= gravity*delta
				velocity.y -= jump_force*jmp*delta
				jumps += 1
		if Input.is_action_just_pressed("dash"):
			var direction = 1 if $AnimatedSprite2D.flip_h else -1
			velocity.x += direction*dash_power*delta
			jumps -= 1
		
		if Input.is_action_pressed("left"):
			$AnimatedSprite2D.flip_h = false
			if is_on_floor():
				$AnimatedSprite2D.play("walk")
			else:
				$AnimatedSprite2D.play("default")
		elif Input.is_action_pressed("right"):
			$AnimatedSprite2D.flip_h = true
			if is_on_floor():
				$AnimatedSprite2D.play("walk")
			else:
				$AnimatedSprite2D.play("default")
		else:
			$AnimatedSprite2D.play("default")
		
		velocity.x += Input.get_axis("left", "right")*delta*speed	
	
	if Input.is_key_pressed(KEY_R):
		kill()
	
	current_speed = abs(velocity.x)
	
	
	#$Weapon.look_at(get_global_mouse_position())
	
	var mouse_pos = get_global_mouse_position()
	var angle = position.direction_to(mouse_pos).angle()
	var gun_x = cos(angle) * weapon_orbit_radius
	var gun_y = sin(angle) * weapon_orbit_radius
	
	$Weapon.position = Vector2(gun_x, gun_y)
	$Weapon.look_at(mouse_pos)
	
	# TODO ammo
	if Input.is_action_just_pressed("shoot"):
		if current_weapon == "Shotgun":
			apply_knockback(angle, 50000)
	elif Input.is_action_just_pressed("altshoot"):
		print("altshoot implement me")
	
	move_and_slide()

func apply_knockback(weapon_angle: float, knockback_strength: float) -> void:
	var knockback_direction = -Vector2(cos(weapon_angle), sin(weapon_angle))  # Inverse direction of the weapon's angle
	var knockback_force = knockback_direction * knockback_strength
	
	velocity += knockback_force*get_physics_process_delta_time()

func on_collect_coin(area: Area2D):
	await get_tree().physics_frame
	var areas = area.get_overlapping_areas()
	var coins = []
	for x in areas:
		if x.is_in_group("coin"):
			coins.append(x)
	for x in coins:
		World.instance.coins += 1
		x.get_node("AnimationPlayer").play("collect")
	

func damage(amount: int):
	health -= max(amount, 0)
	if health == 0:
		kill()

func kill():
	health = 0
	Leaderboards.instance._upload_score(World.instance.score)
	print(Leaderboards.instance._get_leaderboards())
