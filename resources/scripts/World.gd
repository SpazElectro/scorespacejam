extends Node2D
class_name World

var coins = 0
var _score = 0
var score = 0:
	get:
		return (-local_player.position.y+583) + (coins*100)

static var instance: World

@onready var local_player: Player = $Player
@onready var coin_template = $Coins/CoinTemplate
@onready var coins_container = $Coins
@onready var jump_pads_container = $JumpPads

var jump_pad_scene: PackedScene = preload("res://resources/scenes/jump_pad.tscn")

var spawn_point

func _ready():
	instance = self
	
	generate_content_below(null, null, 0)
	
	#create_platform(15, 18, 3)
	if spawn_point:
		local_player.position = spawn_point

var times_generated = 0
@onready var genpointtemplate = $GenerationPointTemplate
func generate_content_below(asdf, p, player_y: float):
	if asdf and (asdf.is_in_group("coin") or asdf.is_in_group("jump_pad")):
		return
	
	var _player_y = player_y
	player_y *= -120
	var previous_x = 0
	var pl
	
	for y in range(int(player_y) - 100, int(player_y) + 15, 3):
		var new_x = randi_range(0, 16)
		while previous_x == new_x:
			new_x = randi_range(0, 16)
		
		if not pl:
			pl = create_platform(new_x, y, randi_range(1, 6))
		else:
			create_platform(new_x, y, randi_range(1, 6))
		previous_x = new_x
	
	if p:
		p.queue_free()
	
	create_walls(player_y-200, abs(player_y)+200)
	
	print("Generated at ", player_y)
	var point = genpointtemplate.duplicate()
	point.global_position = pl
	point.position.x = 0
	point.position.y += 200
	point.show()
	point.connect("area_entered", generate_content_below.bind(point, _player_y + 1), CONNECT_DEFERRED)
	add_child(point)
	times_generated += 1

func _process(delta):
	var step = 100 * abs(score-_score) * delta
	
	if _score < score:
		_score += step
		if _score > score:
			_score = score
	elif _score > score:
		_score -= step
		if _score < score:
			_score = score
	
	$UI/Score.text = str(int(_score))
	$UI/Speed.text = "YPOS: %f" % [
		local_player.position.y,
	]

func set_cell(x, y, tx, ty):
	$TileMapLayer.set_cell(Vector2i(x, y), 0, Vector2i(tx, ty))

func get_cell(x: int, y: int) -> Variant:
	var tile = $TileMapLayer.get_cell_atlas_coords(Vector2i(x, y))
	if tile.x == -1 and tile.y == -1:
		return -1
	return tile

func create_platform(x: int, y: int, width: int):
	var clamped_x = clamp(x, 0, 15)
	
	if clamped_x >= 15:
		width = 1
	if clamped_x+width >= 19:
		width = width-clamped_x
	
	var pattern = [0, 2, 4]
	var ylevel = pattern[times_generated % 3]
	
	var jump_pads = []
	var coin: Area2D
	
	if width > 1:
		set_cell(clamped_x, y, 1, ylevel)
		
		var last_was_prop = false
		for i in range(1, width):
			var current_x = clamped_x + i
			
			if int(i) == int(float(width) / 2):
				coin = coin_template.duplicate()
				coin.process_mode = Node.PROCESS_MODE_INHERIT
				coin.show()
				coin.global_position = $TileMapLayer.to_global($TileMapLayer.map_to_local(Vector2i(current_x, y - 2)))
				coins_container.add_child(coin)
				spawn_point = coin.global_position
			if not last_was_prop:
				if i == width-1 and randi_range(1, 10) >= 7:
					if ylevel == 4:
						set_cell(current_x, y-1, 5+randi_range(-1, 0), 7)
						last_was_prop = true
				if ylevel == 0 and randi_range(1, 10) >= 7:
					set_cell(current_x, y-1, 4+randi_range(0, 3), 6)
					last_was_prop = true
			else: last_was_prop = false
			
			if y <= 0 and (i == width-1 or i == 0) and randi_range(1, 20) >= 15:
				jump_pads.append([current_x, y])
			
			set_cell(current_x, y, 2, ylevel)
		
		set_cell(clamped_x + width - 1, y, 3, ylevel)
	else:
		coin = coin_template.duplicate()
		coin.process_mode = Node.PROCESS_MODE_INHERIT
		coin.show()
		coin.global_position = $TileMapLayer.to_global($TileMapLayer.map_to_local(Vector2i(clamped_x, y - 2)))
		coins_container.add_child(coin)
		spawn_point = coin.global_position
		set_cell(clamped_x, y, 0, ylevel)
	
	var jump_pad_cooldown = 0
	for t in jump_pads:
		var cell = get_cell(t[0], t[1]-1)
		if typeof(cell) != TYPE_INT:
			continue
		cell = get_cell(t[0], t[1]-2)
		if typeof(cell) != TYPE_INT:
			continue
		if jump_pad_cooldown > 0:
			jump_pad_cooldown -= 1
			continue
		
		var pad = jump_pad_scene.instantiate()
		pad.global_position = $TileMapLayer.to_global($TileMapLayer.map_to_local(Vector2i(t[0], t[1])))
		pad.global_position.y -= 36
		jump_pads_container.add_child(pad)
		jump_pad_cooldown = 3
	
	return coin.global_position

func create_walls(from: int, to: int):
	# 7 2
	for y in range(from, to):
		set_cell(-1, y, 7, 2)
		set_cell(16, y, 7, 2)

func update_health():
	var heart_rect = Rect2(Vector2(72, 36), Vector2(18, 18))
	var no_heart_rect = Rect2(Vector2(108, 36), Vector2(18, 18))
	
	for i in range(local_player.max_health):
		var health_node = get_node("UI/Health/" + str(i + 1))
		if i < local_player.health:
			health_node.region_rect = heart_rect
		else:
			health_node.region_rect = no_heart_rect
	
	if local_player.health == 0:
		$UI/DeadMenu.visible = true
		$Lava.base_speed = 0

func on_retry():
	get_tree().reload_current_scene()
