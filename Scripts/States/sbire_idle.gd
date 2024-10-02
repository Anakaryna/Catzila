extends State
class_name EnemyIdle

@export var enemy: CharacterBody2D
@export var move_speed := 10.0

@onready var alert_icon: AnimatedSprite2D = enemy.get_node("AlertIcon") 
@onready var alert_timer: Timer = enemy.get_node("AlertTimer")  
@onready var detection_sound: AudioStreamPlayer2D = enemy.get_node("DetectionSound")

var player: CharacterBody2D
var move_direction: Vector2
var wander_time: float
var anim_direction: String = "down" 

@onready var sprite: AnimatedSprite2D = enemy.get_node("AnimatedCat")

# Function to randomize enemy wandering direction
func randomize_wander():
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, 3)
	update_animation_direction()

func Enter():
	player = get_tree().get_first_node_in_group("Player")
	randomize_wander()
	alert_icon.visible = false 
	alert_timer.timeout.connect(_on_alert_timer_timeout.bind(self))

func Update(delta: float):
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()

func Physics_Update(delta: float):
	if enemy:
		enemy.velocity = move_direction * move_speed
		enemy.move_and_slide()
	
	var direction = player.global_position - enemy.global_position

	if direction.length() < 120:
		show_alert_icon()
		play_detection_sound()
		Transitioned.emit(self, "follow")  # Emit transition to Follow state

# Function to show the exclamation point and start the timer
func show_alert_icon():
	alert_icon.visible = true
	alert_icon.play("your_exclamation_animation")
	alert_timer.start()  

# Function to hide the exclamation point after the timer finishes
func _on_alert_timer_timeout():
	alert_icon.visible = false  
	
# Function to play the detection sound
func play_detection_sound():
	if detection_sound:
		detection_sound.play() 

# Function to update animation direction
func update_animation_direction():
	var base_anim = "idle_"
	if move_direction.length() > 0:
		base_anim = "move_"

	var flip_x = false
	if move_direction.y > 0:
		anim_direction = "down"
	elif move_direction.y < 0:
		anim_direction = "up"
	elif move_direction.x < 0:
		anim_direction = "left"
		flip_x = true
	elif move_direction.x > 0:
		anim_direction = "right"
		flip_x = false
	
	var animation_name = base_anim + anim_direction
	sprite.play(animation_name)
	sprite.flip_h = flip_x
