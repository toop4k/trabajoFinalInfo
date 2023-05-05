extends Area2D

export var trapNum = 0
export(int, -360, 360) var direction
export(int, 0, 100) var speed
var trapTime

func _process(_delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("Kid"):
			trapTime = true
	
	if get_tree().current_scene.has_node("Killers/Traps") && trapTime:
		for trap in get_tree().current_scene.get_node("Killers/Traps").get_children():
			if trap.trapNum == trapNum:
				trap.position += Vector2(speed, 0).rotated(deg2rad(direction))

func restart():
	trapTime = false
