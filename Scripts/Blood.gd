extends KinematicBody2D

var speed
var grav
var off

func _ready():
	randomize()
	$Sprite.frame = floor(rand_range(0, 26))
	
	rotation = rand_range(0, 35) * 10
	speed = rand_range(2, 6)
	grav = rand_range(0.1, 0.2) * global.grav
	off = rand_range(0.2, 0.4)
	
	var timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", self, "_on_Timer_timeout")
	timer.start(0.1)

func _process(_delta):
	var velocity = Vector2(speed, 0).rotated(rotation)
	velocity.y += grav * global.grav
	grav += off
	
	var collision = move_and_collide(velocity)
	if collision:
		if collision.collider.name == "Tiles":
			speed = 0
			grav = 0
			off = 0
			$CollisionShape2D.disabled = true

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Timer_timeout():
	$CollisionShape2D.disabled = false
