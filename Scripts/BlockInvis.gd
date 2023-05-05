extends StaticBody2D

func _ready():
	restart()

func _process(_delta):
	if get_tree().get_nodes_in_group("Kid").size() > 0:
		var player = get_tree().get_nodes_in_group("Kid")[0]
		if !visible && position.distance_to(player.position) <= 36:
			$SFX.play()
			show()

func restart():
	hide()
