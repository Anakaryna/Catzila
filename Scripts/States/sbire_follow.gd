extends State
class_name EnemyFollow

@export var enemy: CharacterBody2D
@export var move_speed := 40.0

var player: CharacterBody2D
@onready var sprite: AnimatedSprite2D = enemy.get_node("AnimatedCat")
var anim_direction: String = "down"

func Enter():
	player = get_tree().get_first_node_in_group("Player")
	print("Entered follow state")

func Physics_Update(delta: float):
	var direction = player.global_position - enemy.global_position
	
	if direction.length() > 100:
		enemy.velocity = direction.normalized() * move_speed
		enemy.move_and_slide()

		# Update the animation based on movement
		update_animation_direction(enemy.velocity)
	else:
		enemy.velocity = Vector2()

	# Only switch back to idle if the player is much farther away
	if direction.length() > 240:
		print("Switching to idle state")
		Transitioned.emit(self, "idle")

# Update the animation direction based on velocity
func update_animation_direction(velocity: Vector2):
	var base_anim = "idle_"
	if velocity.length() > 0:
		base_anim = "move_"
	
	# Prioritize horizontal movement if it's greater than vertical
	if abs(velocity.x) > abs(velocity.y):
		if velocity.x > 0:
			anim_direction = "right" 
		elif velocity.x < 0:
			anim_direction = "left"
	else:
		if velocity.y > 0:
			anim_direction = "down"
		elif velocity.y < 0:
			anim_direction = "up"
	
	# Set the animation based on direction without flipping
	var animation_name = base_anim + anim_direction
	sprite.play(animation_name)
