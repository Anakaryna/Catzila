extends Node2D

@onready var player: CharacterBody2D = %player
@onready var sprite: AnimatedSprite2D = %player/AnimatedSprite2D

const SPEED = 100 # px per second

var direction: Vector2
var anim_direction: String = "down"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#EventBus.level_started.emit()
	#EventBus.level_started.connect(func(): pass)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_dt: float) -> void:
	# movement
	var ix = Input.get_axis("player_left", "player_right")
	var iy = Input.get_axis("player_up", "player_down")
	var iv = Vector2(ix, iy).normalized()
	direction = iv
	player.velocity = iv * SPEED
	player.move_and_slide()
	
	# animation
	var base_anim = "idle_" if direction.length() < .1 else "move_"
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
