extends Area2D

const HELLO_MINE_TURTLE = preload("res://assets/homeMade/hello mine turtle.mp3")
@onready var player: CharacterBody2D = %player
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var explosion_area: Area2D = $explosionArea

var destination: Vector2 = Vector2(150, 200)
var movementSpeed = 170
var fused = false
var exploded = false
var fuseStarted: float = 0
var fuseDuration: float = 1500
var audioDuration: float = 2840
var explodedBodies = Array()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not abs(position.x - destination.x) < 1 and not abs(position.y - destination.y) < 1:
		position += (destination - position).normalized() * movementSpeed * delta
	else:
		#print("im on scene")
		self.get_overlapping_bodies().any(collisionEnter)
	if fused and not exploded and Time.get_ticks_msec() >= fuseStarted + fuseDuration:
		explosion_area.get_overlapping_bodies().all(sendDamage)
		pass
	if fused and Time.get_ticks_msec() >= fuseStarted + audioDuration:
		queue_free()
	pass


func collisionEnter(body):
	if body == player and not fused:
		if not audio_stream_player_2d.playing:
			audio_stream_player_2d.stream = HELLO_MINE_TURTLE
			audio_stream_player_2d.play()
		print("Hello :)")
		fused = true
		fuseStarted = Time.get_ticks_msec()
	pass

func sendDamage(body):
	if not explodedBodies.has(body):
		explodedBodies.append(body)
		$"..".emit_signal("signal_damage", body, 100)
		print("im dead lol")
	pass
