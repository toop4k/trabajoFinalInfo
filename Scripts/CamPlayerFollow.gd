extends Camera2D

func _ready():
	yield(get_tree().create_timer(0.05), "timeout")
	if get_tree().get_nodes_in_group("Kid").size() > 0:
		position = get_tree().get_nodes_in_group("Kid")[0].position
		yield(get_tree().create_timer(0.05), "timeout")
		smoothing_enabled = true
		limit_smoothed = true

func _process(_delta):
	if get_tree().get_nodes_in_group("Kid").size() > 0:
		position = get_tree().get_nodes_in_group("Kid")[0].position
