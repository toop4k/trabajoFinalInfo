extends CanvasLayer

func _process(delta):
	$TheStuff.visible = get_tree().paused
	
	$TheStuff/Deaths.text = "Deaths: " + str(global.deaths)
	$TheStuff/Time.text = "Time: " + str(global.time.hours) + ":" + str(global.time.minutes) + ":" + str(global.time.seconds)
	$TheStuff/Volume.text = "Volume: " + str(round(abs(global.masterVolume * 100))) + "%"
	
	if get_tree().paused:
		if Input.is_action_pressed("upButton") && global.masterVolume < 1:
			global.masterVolume += 0.01
		if Input.is_action_pressed("downButton") && global.masterVolume > 0:
			global.masterVolume -= 0.01
