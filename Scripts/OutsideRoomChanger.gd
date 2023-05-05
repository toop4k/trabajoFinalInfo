extends Area2D

export(PackedScene) var scene

func _process(_delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("Kid"):
			get_tree().change_scene_to(scene)
