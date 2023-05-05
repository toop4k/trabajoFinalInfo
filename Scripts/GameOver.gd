extends CanvasLayer

var time = 0
func _process(_delta):
	time += 1
	if time == 30:
		$Sprite.visible = true

func restart():
	queue_free()
