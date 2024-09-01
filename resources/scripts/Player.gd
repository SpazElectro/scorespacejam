extends CharacterBody2D
class_name Player

@export var weapon_orbit_radius: float = 20.0
@export var speed = 500
@export_category("Shotgun")
@export_range(1.0, 5.0) var shoot_timer: float = 1
@export var recoil: float = 80
@export_category("Forces")
@export var jump_force = 20000
@export var walljump_force = 20000
@export var dash_power = 30000
@export_category("Limits")
@export var max_jumps = 2
@export var max_dashes = 3
@export var max_health = 3
@export var max_speed = 2000

var _shoot_timer = 0
var jump_pad_jumps = 0
var current_speed = 0.0
var jumps = 0
var dashes = max_dashes
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health = max_health:
	set(value):
		health = value
		World.instance.update_health()

func _ready():
	$ShotgunSound.volume_db = Shared.get_aud_vol()

func _process(delta):
	if not is_on_floor():
		velocity.y += gravity*delta
	else:
		jumps = 0
		dashes = max_dashes
	
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
		if Input.is_action_just_pressed("dash") and dashes > 0:
			var direction = 1 if $AnimatedSprite2D.flip_h else -1
			velocity.x += direction*dash_power*delta
			jumps = 0 # nicer control
			dashes -= 1
			$DashTimer.start()
		
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
			apply_knockback(angle, recoil*1000)
			$ShotgunSound.pitch_scale = randf_range(0.7, 1.0)
			$ShotgunSound.play()
			_shoot_timer = shoot_timer
		if _shoot_timer > 0:
			_shoot_timer -= delta
		
		# so the player doesn't get launched into space immediately
		if Time.get_ticks_msec() % 1000 <= 10:
			jump_pad_jumps = 0
	
	if velocity.y <= -max_speed:
		velocity.y = -max_speed
	
	move_and_slide()

func apply_knockback(weapon_angle: float, knockback_strength: float) -> void:
	var knockback_direction = -Vector2(cos(weapon_angle), sin(weapon_angle))  # Inverse direction of the weapon's angle
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

func kill():
	health = 0
	velocity.x = 0
	velocity.y = 0
	
	if Shared.get_gamemode() == Shared.GAMEMODE.ENDLESS:
		Leaderboards._upload_score(World.instance.score)
		Leaderboards._get_leaderboards()

func _on_dash_timer_timeout():
	dashes = min(dashes+1, max_dashes)
