extends KinematicBody2D
const BloodEmitterScene = preload("res://Scenes/BloodEmitter.tscn")
const GameOverScene = preload("res://Scenes/GameOver.tscn")

var hspeed = 0
var vspeed = 0

var frozen = false # Establece si la jugadora puede moverse o no
var inWater

var jump
var jump2
var grav

var jumpTime = 3

var djump = 1 # Permita que el jugador salte dos veces tan pronto como aparezca
var maxHSpeed = 3 #Velocidad máxima horizontal
var maxVSpeed = 9 # Velocidad máxima vertical
var prevPos = Vector2()
var slipBlockTouching
var onVineR
var onVineL
var slip = 0.2
var canWalljump = true
var slide = 0

func _ready():
	$Sprite.flip_h = false # Establece la dirección hacia la que mira el jugador (falso hacia la derecha, verdadero hacia la izquierda)
	
	if get_tree().current_scene.name != "End":
		if global.savePlayerPos:
			position = global.savePlayerPos
			
		if global.saveGrav:
			global.grav = global.saveGrav
		else:
			global.saveGrav = global.grav
	else:
		global.gameClear = true
	
	if global.saveScene:
		if get_tree().current_scene.name in str(global.saveScene):
			if global.saveRoom:
				for room in get_tree().current_scene.get_node("Rooms").get_children():
					if room.current && room != global.saveRoom:
						room.current = false
					if room == global.saveRoom:
						room.current = true

func _physics_process(delta):
	grav = 0.4 * global.grav #Establece la gravedad del jugador
	jump = 8 * global.grav # Establece qué tan rápido salta el jugador
	jump2 = 6.5 * global.grav # Establece qué tan rápido el jugador salta dos veces
	
	
	
	# Voltea al jugador dependiendo de la dirección de la gravedad.
	if global.grav == 1:
		scale.y = 1
	else:
		scale.y = -1
	
	var L = Input.is_action_pressed("leftButton")
	var R = Input.is_action_pressed("rightButton")
	
	var h = 0 # Realiza un seguimiento si la jugadora se mueve a la izquierda / derecha
	
	if !frozen: # No te muevas si está congelada
		if R:
			h = 1
		elif L:
			h = -1
	
	if h != 0: # El jugador se esta moviendo
		if !onVineL && !onVineR: # Asegúrese de que no estemos actualmente en una enredada
			$Sprite.flip_h = bool(clamp(h, -1, 0)) # Establece la dirección hacia la que se enfrenta el jugador
			$CollisionShape2D.scale.x = h
		
		if h == -1 && !onVineR || h == 1 && !onVineL: # Asegúrese de que no nos estemos moviendo de una vid (eso se maneja más adelante)
			if !slipBlockTouching: # Sin tocar un bloque deslizante, muévase inmediatamente a toda velocidad
				hspeed = maxHSpeed * h
			else: # Tocando un bloque deslizante, usa la aceleración
				hspeed += slip * h
				
				if abs(hspeed) > maxHSpeed:
					hspeed = maxHSpeed * h
		
		$AnimationPlayer.play("Run")
	else: # Jugador no se mueve
		
		if !slipBlockTouching: #Sin tocar un bloque deslizante, deténgase inmediatamente.
			hspeed = 0
		else: # Tocando un bloque deslizante, disminuya la velocidad
			if hspeed > 0:
				hspeed -= slip
				
				if hspeed <= 0:
					hspeed = 0
			
			elif hspeed < 0:
				hspeed += slip
				
				if hspeed >= 0:
					hspeed = 0
		
		$AnimationPlayer.play("Idle")
	
	# Correr animaciones de salto y caída.
	if !is_on_floor():
		if vspeed < 0:
			$AnimationPlayer.play("Jump")
		else:
			$AnimationPlayer.play("Fall")
	
	if abs(vspeed) > maxVSpeed: # Compruebe si se mueve más rápido verticalmente que la velocidad máxima
		vspeed = sign(vspeed) * maxVSpeed
	
	vspeed += grav # Aplique la gravedad a la velocidad v actual para verificar dónde estará el jugador
	
	# Comprobar colisiones horizontales
	if is_on_wall():
		hspeed = 0
	
	# Comprobar colisiones verticales
	if is_on_floor() or is_on_ceiling():
		if vspeed <= 0 && global.grav == -1:
			djump = 1
		elif vspeed >= 0 && global.grav == 1:
			djump = 1
		
		vspeed = global.grav * 0.1
	
	# Verifique los botones para las acciones del jugador
	if !frozen: # Compruebe si está congelado antes de hacer nada
		if Input.is_action_just_pressed("jumpButton"):
			jump()
			jumpTime = 3
		if Input.is_action_just_released("jumpButton"):
			vJump()
		if Input.is_action_just_pressed("scuicideButton"):
			kill()
	
	jumpTime -= 1

	prevPos = position
	
	# Agregue velocidades
	move_and_slide(Vector2(hspeed + slide, vspeed) / delta, Vector2(0, global.grav * -1))
	position = Vector2(round(position.x), position.y)
	# Detectar jugador en los bordes de la pantalla
	if get_parent().has_node("Rooms"):
		for cam in get_parent().get_node("Rooms").get_children():
			if cam.current:
				var check = camCheck(cam)
				if check:
					if check.axis == "x":
						for camm in get_parent().get_node("Rooms").get_children():
							if camm.position == Vector2(cam.position.x + 800 * check.dir, cam.position.y):
								camm.current = true
								cam.current = false
						if cam.current:
							kill()
					elif check.axis == "y":
						for camm in get_parent().get_node("Rooms").get_children():
							if camm.position == Vector2(cam.position.x, cam.position.y + 608 * check.dir):
								camm.current = true
								cam.current = false
						if cam.current:
							kill()

# Hace que el jugador salte
func jump():
	if is_on_floor() or inWater == 0:
		$SFXplayer.stream = preload("res://Audio/Jump.wav")
		$SFXplayer.play()
		vspeed = -jump
		djump = 1
	elif djump == 1 or inWater == 1 or inWater == 2 or global.infJump:
		if onVineL or onVineR:
			return
		$SFXplayer.stream = preload("res://Audio/Jump2.wav")
		$SFXplayer.play()
		vspeed = -jump2
		
		if inWater != 2:
			djump = 0
		else:
			djump = 1

# Hace que el jugador pierda impulso vertical ascendente
func vJump():
	if vspeed * global.grav < 0:
		vspeed *= 0.45


# Mata al jugador
func kill():
	global.deathMusic.volume_db = 0
	global.deathMusic.play()
	global.fadeMusic()
	if !get_parent().has_node("DeathPos"):
		var deathPos = Position2D.new()
		deathPos.name = "DeathPos"
		get_parent().add_child(deathPos)
		deathPos.position = position
		var deathsfx = AudioStreamPlayer.new()
		deathPos.add_child(deathsfx)
		deathsfx.stream = preload("res://Audio/Death.wav")
		deathsfx.play()
		
		var bloodEmitter = BloodEmitterScene.instance()
		get_parent().add_child(bloodEmitter)
		
		var gameOver = GameOverScene.instance()
		get_parent().add_child(gameOver)
		
		queue_free()

func camCheck(cam):
	if position.x > cam.position.x + 400:
		return {"axis":"x", "dir":1}
	elif position.x < cam.position.x - 400:
		return {"axis":"x", "dir":-1}
	elif position.y > cam.position.y + 304:
		return {"axis":"y", "dir":1}
	elif position.y < cam.position.y - 304:
		return {"axis":"y", "dir":-1}
	return false

func platformCollision(other):
	if global.grav == 1: # Compruebe si está en la parte superior de la plataforma (cuando está boca arriba)
		if position.y - vspeed / 2 + 16 <= other.position.y:
			if vspeed <= 0 && jumpTime <= 0:
				position.y = other.position.y - 25 # Ajustar a la plataforma
				vspeed = 0
		
		djump = 1
	else: # Compruebe si está en la parte superior de la plataforma (cuando se voltea)
		if position.y - vspeed / 2 - 16 >= other.position.y:
			if vspeed >= 0 && jumpTime <= 0:
				position.y = other.position.y + 25 # Ajustar a la plataforma
				vspeed = 0
		
		djump = 1

func _on_Timer_timeout():
	canWalljump = true
