extends Node
const BloodScene = preload("res://Scenes/Blood.tscn")

var time = 0

func _ready():
	randomize()
	var bloodAmount = round(rand_range(160, 320))
	if get_parent().has_node("Blood"):
		while get_parent().get_node("Blood").get_child_count() < bloodAmount:
			var blood = BloodScene.instance()
			get_parent().get_node("Blood").add_child(blood)
			blood.position = get_parent().get_node("DeathPos").position

func _process(_delta):
	time += 1
	
	if time == 20:
		restart()

func restart():
	get_parent().get_node("DeathPos").queue_free()
	queue_free()
