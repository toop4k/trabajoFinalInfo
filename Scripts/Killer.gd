extends Area2D

export var flip = bool()
export var trapNum = 0
var startPos

func _ready():
	$Sprite.flip_h = flip
	if get_parent().name == "Traps":
		add_to_group("Restart")
		startPos = global_position

func _process(_delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("Kid"):
			 body.kill()

func restart():
	global_position = startPos
