extends Node2D

@onready var player: CharacterBody2D = %player
const MINE_TURTLE = preload("res://mine_turtle.tscn")
const SPIDER = preload("res://spider.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var mine = MINE_TURTLE.instantiate()
	#mine.destination = Vector2(500, 0)
	#mine.player = player
	#add_child(mine)
	#
	#var spider = SPIDER.instantiate()
	#spider.destination = Vector2(300, 400)
	#add_child(spider)
	pass
