extends CharacterBody2D

class_name Sbire

@export var damage: float = 20

@onready var sprite: AnimatedSprite2D = $AnimatedCat

var health = 100

func _ready() -> void:
	EventBus.signal_damage.connect(_on_signal_damage)

func _physics_process(delta):
	move_and_slide()
	

func _process(delta: float) -> void:
	if health <= 0:
		queue_free()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	EventBus.signal_damage.emit(body, damage)

func _on_signal_damage(body: CharacterBody2D, damagePoints: float):
	if body == self:
		var tw = sprite.create_tween()
		tw.tween_property(sprite, "modulate", Color.RED, .05)
		tw.tween_property(sprite, "modulate", Color.WHITE, .05)
		health -= damagePoints
