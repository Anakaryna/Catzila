extends Node2D

@onready var player: CharacterBody2D = %player
@onready var sprite: AnimatedSprite2D = %player/AnimatedSprite2D

@export var SPEED = 100 # px per second

var direction: Vector2
var anim_direction: String = "down"

var attacking: bool = false
var dead: bool = false
var player_health: float = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#EventBus.level_started.emit()
	#EventBus.level_started.connect(func(): pass)
	sprite.animation_finished.connect(_on_anomation_finished)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_dt: float) -> void:
	# movement
	var ix = Input.get_axis("player_left", "player_right")
	var iy = Input.get_axis("player_up", "player_down")
	var iv = Vector2(ix, iy).normalized()
	direction = iv if not attacking else direction # let's us keep the same direction while playing the attack animation
	player.velocity = iv * SPEED
	player.move_and_slide()
	
	# animation
	animatePlayer()

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
	var flip_x = false
	if direction.y > 0:
		anim_direction = "down"
	elif direction.y < 0:
		anim_direction = "up"
	elif direction.x < 0:
		anim_direction = "right"
		flip_x = true
	elif direction.x > 0:
		anim_direction = "right"
	
	var animation_name = base_anim + anim_direction
	sprite.play(animation_name)
	sprite.flip_h = flip_x

func _on_anomation_finished() -> void:
	if sprite.animation.begins_with("attack_"):
		attacking = false
		#print("done attacking")
	if sprite.animation == "die":
		dead = true
