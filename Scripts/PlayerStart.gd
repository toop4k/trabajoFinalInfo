extends Position2D

func _ready():
	hide()
	restart()
	
	

func restart():
	var player = preload("res://Scenes/Player.tscn").instance()
	get_parent().call_deferred("add_child", player)
	player.position = position
