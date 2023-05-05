extends Area2D

export var refreshTime = 100
var refreshing
var time = 0

func _process(_delta):
	$Sprite.scale.y = global.grav
	if refreshing:
		time += 1
	if time == 100:
		refreshing = false
		time = 0
		$Sprite.visible = true
		$CollisionShape2D.disabled = false
		
	for body in get_overlapping_bodies():
		if body.is_in_group("Kid") and !refreshing:
			body.djump = 1
			$Sprite.visible = false
			$CollisionShape2D.disabled = true
			refreshing = true
