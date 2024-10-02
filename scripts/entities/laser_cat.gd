extends CharacterBody2D

const SPEED = 90

@onready var laserModule: LaserShooter = $LaserShooterModule
@onready var texture: AnimatedSprite2D = $LaserCatTexture

var target: Node2D = null
var anim_base: String = "idle"
var anim_direction: String = "down"
var is_laser_shooting: bool

func _ready() -> void:
	EventBus.is_laser_shooting.connect(func(is_laser_shooting: bool, _timing: float):
		self.is_laser_shooting = is_laser_shooting
	)

func _physics_process(delta: float) -> void:
	var input = get_movement_direction()
	
	velocity = input.normalized() * SPEED
	
	animate()
	move_and_slide()

# TODO: Put AI logic in this function to determine movement 
func get_movement_direction() -> Vector2:
	if (target):
		return position - target.position
		
	return Vector2.ZERO

func animate():
	if (target):
		# Update direction
		anim_base = "attack" if is_laser_shooting else "move"
		var angle = get_angle_to(target.position)
		if (-PI / 4 <= angle && angle < PI / 4):
			anim_direction = "right"
		if (PI / 4 <= angle && angle < 3 * PI / 4):
			anim_direction = "down"
		if (3 * PI / 4 <= angle || angle < - 3 * PI / 4):
			anim_direction = "left"
		if (- 3 * PI / 4 <= angle && angle < - PI / 4):
			anim_direction = "up"
	else:
		anim_base = "idle"
	
	texture.animation = anim_base + "_" + anim_direction

func _on_target_detection(body: Node2D) -> void:
	target = body
	laserModule.target = target


func _on_target_exited(body: Node2D) -> void:
	target = null
