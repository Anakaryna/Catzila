extends Area2D

const SPIDER_LAUGH = preload("res://assets/homeMade/spider laugh.mp3")

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var destination: Vector2
var movementSpeed = 170
var dieOnDestination = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	destination = position
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
		if not audio_stream_player_2d.playing:
			audio_stream_player_2d.stream = SPIDER_LAUGH
			audio_stream_player_2d.play()
		dieOnDestination = true
		destination = position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
