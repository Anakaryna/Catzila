extends CharacterBody2D

class_name Sbire

@export var damage: float = 20

func _physics_process(delta):
	move_and_slide()
	


func _on_hurtbox_body_entered(body: Node2D) -> void:
	EventBus.signal_damage.emit(body, damage)
