tool
extends Area2D

export(String, "-1", "1") var direction = "-1"

func _ready():
	if !Engine.editor_hint:
		direction = int(direction)
		if direction == -1:
			$Sprite0.visible = true
			$Sprite1.visible = false
		elif direction == 1:
			$Sprite1.visible = true
			$Sprite0.visible = false
			$CollisionPolygon2D.scale.y = -1
		else:
			queue_free()

func _process(_delta):
	if Engine.editor_hint:
		if direction == "-1":
			$Sprite0.visible = true
			$Sprite1.visible = false
		elif direction == "1":
			$Sprite1.visible = true
			$Sprite0.visible = false
	else:
		for body in get_overlapping_bodies():
			if body.is_in_group("Kid"):
				if global.grav == direction * -1:
					global.grav = direction
					body.vspeed = 0
