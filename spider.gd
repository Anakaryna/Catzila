extends Area2D


var destination: Vector2 = Vector2(300, 200)
var movementSpeed = 170
var dieOnDestination = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not abs(position.x - destination.x) < 1 and not abs(position.y - destination.y) < 1:
		position += (destination - position).normalized() * movementSpeed * delta
	elif dieOnDestination:
		queue_free()
	else:
		self.get_overlapping_bodies().any(collisionEnter)
	pass


func collisionEnter(body):
	if !dieOnDestination:
		EventBus.handicap.emit(body)
		dieOnDestination = true
		destination = Vector2(500, 300)
