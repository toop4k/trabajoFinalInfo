extends Area2D

func _process(_delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("Kid") and visible:
			$SFX.play()
			hide()

func restart():
	show()
