extends Control

@onready var template = $Template

func format_number_with_commas(number: int) -> String:
	var number_str = str(number)
	var result = ""
	var count = 0
	
	for i in range(number_str.length() - 1, -1, -1):
		result = number_str[i] + result
		count += 1
		if count == 3 and i != 0:
			result = "," + result
			count = 0
	
	return result

func init_board(key: String):
	var data = await Leaderboards._get_leaderboards(key)
	
	if data:
		var items = data.items
		if items:
			var i = 0
			for item in items:
				var e: Label = template.duplicate()
				e.text = str(i+1)+". " + format_number_with_commas(item.score)
				e.visible = true
				if i == 0:
					# first place
					e.add_theme_color_override("font_color", Color(1, 0.5, 0, 1))
				elif i == 1:
					# second place
					e.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
				elif i == 2:
					# third place
					e.add_theme_color_override("font_color", Color(0.6, 0.3, 0, 1))
				get_node(key).get_node("VBoxContainer").add_child(e)
				i += 1

func _ready():
	await get_tree().create_timer(3.0).timeout
	
	init_board("score")
	init_board("coins")
	init_board("snowman")
