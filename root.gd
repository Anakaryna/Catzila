extends Node2D

@onready var player: CharacterBody2D = %player
@onready var sprite: AnimatedSprite2D = %player/AnimatedSprite2D

const MINE_TURTLE = preload("res://mine_turtle.tscn")
const SPIDER = preload("res://spider.tscn")

@export var SPEED = 100 # px per second

enum MovementModifier{
	Normal,
	Freeze,
	Reverse
}

var direction: Vector2
var anim_direction: String = "down"

var movementResetTimers: Array[Timer]
var attacking: bool = false
var dead: bool = false
var player_health: float = 100
var moveModifier: MovementModifier = MovementModifier.Normal
var handicapTimer = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mine = MINE_TURTLE.instantiate()
	mine.destination = Vector2(500, 0)
	mine.player = player
	add_child(mine)
	
	var spider = SPIDER.instantiate()
	spider.destination = Vector2(300, 400)
	add_child(spider)
	
	EventBus.signal_damage.connect(_on_signal_damage)
	EventBus.handicap.connect(_on_handicap)
	sprite.animation_finished.connect(_on_anomation_finished)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_dt: float) -> void:
	# movement
	processMovements()
	# animation
	animatePlayer()

func processMovements():
	var ix = Input.get_axis("player_left", "player_right")
	var iy = Input.get_axis("player_up", "player_down")
	var iv = Vector2(ix, iy).normalized()
	if moveModifier == MovementModifier.Reverse:
		iv = Vector2(-ix, -iy).normalized()
	direction = iv if not attacking else direction # let's us keep the same direction while playing the attack animation
	if moveModifier == MovementModifier.Freeze:
		player.velocity = Vector2(0, 0)
	else:
		player.velocity = iv * SPEED
	player.move_and_slide()

func animatePlayer():
	var base_anim
	if dead:
		return
	if player_health <= 0 and not dead:
		sprite.play(&"die")
		return
	elif attacking or Input.is_action_pressed("player_attack"):
		base_anim = "attack_"
		attacking = true
	elif direction.length() < .1:
		base_anim = "idle_"
	else:
		base_anim = "move_"
	var flip_x: bool = sprite.flip_h
	if direction.y > 0:
		anim_direction = "down"
		flip_x = false
	elif direction.y < 0:
		anim_direction = "up"
		flip_x = false
	elif direction.x < 0:
		anim_direction = "right"
		flip_x = true
	elif direction.x > 0:
		anim_direction = "right"
		flip_x = false
	
	var animation_name = base_anim + anim_direction
	sprite.play(animation_name)
	sprite.flip_h = flip_x

func _on_anomation_finished() -> void:
	if sprite.animation.begins_with("attack_"):
		attacking = false
		#print("done attacking")
	if sprite.animation == "die":
		dead = true


func _on_signal_damage(body: CharacterBody2D, damagePoints: float) -> void:
	#print("got a signal")
	if body == player:
		#print("im bleeding")
		player_health -= damagePoints
	pass # Replace with function body.

func _on_handicap(body: CharacterBody2D):
	if body == player:
		var h = randi_range(0, 1)
		if h == 0:
			moveModifier = MovementModifier.Freeze
		if h == 1:
			moveModifier = MovementModifier.Reverse
			
		# Try to use already instantiated timer
		for i in movementResetTimers.size():
			print(movementResetTimers[i].is_stopped())
			if movementResetTimers[i].is_stopped():
				movementResetTimers[i].one_shot = true
				movementResetTimers[i].start(handicapTimer)
				return
		var timer = Timer.new()
		add_child(timer)
		timer.one_shot = true
		timer.timeout.connect(resetMoveModifier)
		timer.start(handicapTimer)
		movementResetTimers.append(timer)

func resetMoveModifier():
	moveModifier = MovementModifier.Normal
