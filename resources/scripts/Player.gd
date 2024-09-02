extends CharacterBody2D
class_name Player

@export var weapon_orbit_radius: float = 20.0
@export var speed = 500
@export_category("Shotgun")
@export_range(1.0, 5.0) var shoot_timer: float = 2.4
@export var recoil: float = 80
@export_category("Forces")
@export var jump_force = 5000
@export var walljump_force = 20000
@export var dash_power = 30000
@export_category("Limits")
@export var max_jumps = 2
@export var max_dashes = 3
@export var max_health = 3
@export var max_speed = 2000
@export var max_jump_time = 0.15

var _shoot_timer  = 0
var jump_pad_jumps = 0
var current_speed = 0.0
var jumps = 0
var dashes = max_dashes
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health = max_health:
	set(value):
		health = value
		World.instance.update_health()
var is_jumping = false
var jump_time = 0.0
var time_alive = 0.0

func _process(delta):
	if not is_on_floor():
		if not is_on_wall():
			velocity.y += gravity*delta
		else:
			velocity.y += (gravity/4)*delta
	else:
		jumps = 0
		is_jumping = false
		dashes = max_dashes
	
	if health > 0:
		time_alive += delta
		
		if Input.is_action_just_pressed("jump"):
			# the position checks are just so we dont
			# walljump on the platforms
			if not is_on_floor() and is_on_wall() and (position.x >= 0 and position.x <= 60 and $AnimatedSprite2D.flip_h == false) or (position.x >= 460 and $AnimatedSprite2D.flip_h == true) and round(velocity.y) != 0:
				# walljump
				is_jumping = false
				jump_time = 0.0
				velocity.x -= (float(round(current_speed/200))/10+1)*(walljump_force*(1 if $AnimatedSprite2D.flip_h else -1)*delta)
				jumps -= 1 # allow the player to jump
			if jumps < max_jumps:
				var jmp = 1
				if jumps == 1:
					jmp = 1.5
				velocity.y -= gravity*delta
				is_jumping = true
				jump_time = 0.0
				velocity.y -= jump_force * jmp * delta
				jumps += 1
		elif Input.is_action_pressed("jump") and is_jumping:
			jump_time += delta
			if jump_time < max_jump_time:
				velocity.y -= gravity * delta
				velocity.y -= jump_force * delta
			else:
				is_jumping = false
		elif Input.is_action_just_released("jump"):
			is_jumping = false
		if Input.is_action_just_pressed("dash") and dashes > 0:
			var direction = 1 if $AnimatedSprite2D.flip_h else -1
			velocity.x += direction*dash_power*delta
			jumps = 0 # nicer control
			dashes -= 1
			$DashTimer.start()
			$DashSound.play()
		
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
	
	current_speed = abs(velocity.x)
	
	if health > 0:
		var mouse_pos = get_global_mouse_position()
		var angle = position.direction_to(mouse_pos).angle()
		var gun_x = cos(angle) * weapon_orbit_radius
		var gun_y = sin(angle) * weapon_orbit_radius
		
		$Weapon.position = Vector2(gun_x, gun_y)
		$Weapon.look_at(mouse_pos)
		
		if Input.is_action_just_pressed("shoot") and _shoot_timer <= 0:
			# check here if the raycast
			# hit a Snowman
			apply_knockback(angle, recoil*1000)
			$ShotgunSound.pitch_scale = randf_range(0.7, 1.0)
			$ShotgunSound.play()
			_shoot_timer = shoot_timer
			
			Camera.shake_camera(recoil, 0.1)
			
			if $Weapon/RayCast2D.is_colliding():
				var col = $Weapon/RayCast2D.get_collider()
				if col is Snowman:
					col._on_area_entered($Area2D)
				elif col is Coin:
					World.instance.coins += 1
					col.get_node("AnimationPlayer").play("collect")
			
			$Weapon/Muzzle.visible = true
			await get_tree().process_frame
			await get_tree().process_frame
			$Weapon/Muzzle.visible = false
		if _shoot_timer > 0:
			_shoot_timer -= delta
		
		# so the player doesn't get launched into space immediately
		if Time.get_ticks_msec() % 1000 <= 10:
			jump_pad_jumps = 0
	
		if velocity.y <= -max_speed:
			velocity.y = -max_speed
	
	move_and_slide()
	
	if position.x < -64:
		position.x = 0
		print("Out of bounds! < -64")
	if position.x > 565:
		position.x = 512-64
		print("Out of bounds! > 565")

func apply_knockback(weapon_angle: float, knockback_strength: float) -> void:
	var knockback_direction = -Vector2(cos(weapon_angle), sin(weapon_angle))
	var knockback_force = knockback_direction * knockback_strength
	
	velocity += knockback_force*get_physics_process_delta_time()

func on_collect_coin(area: Area2D):
	await get_tree().physics_frame
	if (not area.get_parent() is Player) and (not area is Lava):
		return
	var areas = $Area2D.get_overlapping_areas()
	var coins = []
	for x in areas:
		if x.is_in_group("coin"):
			coins.append(x)
	if area is Lava:
		for x in coins:
			x.queue_free()
		return
	
	for x in coins:
		World.instance.coins += 1
		x.get_node("AnimationPlayer").play("collect")
	

func damage(amount: int):
	health -= max(amount, 0)
	if health == 0:
		kill()

var alive = true
func kill():
	if not alive:
		return
	alive = false
	health = 0
	velocity.x = 0
	velocity.y = 0
	
	if Shared.get_gamemode() == Shared.GAMEMODE.ENDLESS:
		Leaderboards._upload_score(World.instance.score)
		Leaderboards._get_leaderboards()
	
	$DeathSound.play()

func _on_dash_timer_timeout():
	dashes = min(dashes+1, max_dashes)
