extends State
class_name EnemyFollow

@export var enemy: CharacterBody2D
@export var move_speed := 40.0

var player: CharacterBody2D

func Enter():
	player = get_tree().get_first_node_in_group("Player")
	print("Entered follow state")

func Physics_Update(delta: float):
	var direction = player.global_position - enemy.global_position
	
	if direction.length() > 100:
		print(direction.length())
		print("Following player")
		enemy.velocity = direction.normalized() * move_speed
		enemy.move_and_slide()
	else:
		enemy.velocity = Vector2()

	# Only switch back to idle if the player is much farther away
	if direction.length() > 240:
		print(direction.length())
		print("Switching to idle state")
		Transitioned.emit(self, "idle")

func Exit():
	# Clean up when leaving the Follow state
	pass
