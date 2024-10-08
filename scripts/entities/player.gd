extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var down_attack_hit_box: Area2D = $DownAttackHitBox
@onready var up_attack_hit_box: Area2D = $UpAttackHitBox
@onready var left_attack_hit_box: Area2D = $LeftAttackHitBox
@onready var right_attack_hit_box: Area2D = $RightAttackHitBox

@export var SPEED = 300 # px per second


enum MovementModifier{
	Normal,
	Freeze,
	Reverse
}

var direction: Vector2
var anim_direction: String = "down"

var movementResetTimers: Array[Timer]
var attacking: bool = false
var attackLanded: bool = false
var dead: bool = false
var player_health: float = 50
var moveModifier: MovementModifier = MovementModifier.Normal
var handicapTimer = 3
var damage = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.signal_damage.connect(_on_signal_damage)
	EventBus.handicap.connect(_on_handicap)
	sprite.animation_finished.connect(_on_anomation_finished)
	pass # Replace with function body.
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_dt: float) -> void:
	# movement
	processMovements()
	# animation
	animatePlayer()
	processAttack()


func processAttack():
	if attacking and not attackLanded:
		if anim_direction == "down":
			down_attack_hit_box.get_overlapping_bodies().all(playerAttack)
		elif anim_direction == "up":
			up_attack_hit_box.get_overlapping_bodies().all(playerAttack)
		elif anim_direction == "right" and sprite.flip_h:
			left_attack_hit_box.get_overlapping_bodies().all(playerAttack)
		elif anim_direction == "right" and not sprite.flip_h:
			right_attack_hit_box.get_overlapping_bodies().all(playerAttack)
	pass

func playerAttack(body: CharacterBody2D):
	if attacking and not attackLanded and body != self:
		attackLanded = true
		EventBus.signal_damage.emit(body, damage)

func processMovements():
	var ix = Input.get_axis("player_left", "player_right")
	var iy = Input.get_axis("player_up", "player_down")
	var iv = Vector2(ix, iy).normalized()
	if moveModifier == MovementModifier.Reverse:
		iv = Vector2(-ix, -iy).normalized()
	direction = iv if not attacking else direction # let's us keep the same direction while playing the attack animation
	if moveModifier == MovementModifier.Freeze:
		self.velocity = Vector2(0, 0)
	else:
		self.velocity = iv * SPEED
	self.move_and_slide()

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
		attackLanded = false
		#print("done attacking")
	if sprite.animation == "die":
		dead = true


func _on_signal_damage(body: CharacterBody2D, damagePoints: float) -> void:
	#print("got a signal")
	if body == self:
		#print("im bleeding")
		player_health -= damagePoints
		var tw = sprite.create_tween()
		tw.tween_property(sprite, "modulate", Color.RED, .05)
		tw.tween_property(sprite, "modulate", Color.WHITE, .05)
	pass # Replace with function body.

func _on_handicap(body: CharacterBody2D):
	if body == self:
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
