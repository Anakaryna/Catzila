class_name LaserShooter

extends Node2D

const RAY_LENGTH = 9999
const RAY_ANGULAR_SPEED = 0.01
const RAY_RETARGET_MAX_DEGREES = PI / 4
const RAY_MIN_WIDTH = 10
const RAY_MAX_WIDTH = 30
const RAY_DAMAGE = 30

@export var target : Node2D

@onready var line : Line2D = $LaserGraphics
@onready var hitbox : CollisionPolygon2D = $LaserHitbox/LaserShape

var curTargetAngle = 0
var laser_vector: Vector2

func _ready() -> void:
	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)
	
	EventBus.is_laser_shooting.connect(func(is_shooting: bool, timing: float):
		if (target == null):
			return
		line.width = RAY_MIN_WIDTH + timing * (RAY_MAX_WIDTH - RAY_MIN_WIDTH)
		var origin = to_global(position)
		var curTargetPosition = get_target_position(target.position, is_shooting)
		if is_shooting:
			# Raycast for "infinite" ray
			var end = origin + (curTargetPosition - origin).normalized() * RAY_LENGTH
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsRayQueryParameters2D.create(origin, end, 0b010)
			var result = space_state.intersect_ray(query)
			
			# Draw result
			line.points[1] = to_local(result.position) if result.has("position") else to_local(end)
			laser_vector = (result.position if result.has("position") else end) - origin
		else:
			line.points[1] = Vector2.ZERO
			laser_vector = Vector2.ZERO
	)

func _physics_process(delta: float) -> void:
	update_hitbox()
	pass

func update_hitbox() -> void:
	# Get shape information
	var w = Vector2(-laser_vector.y, laser_vector.x).normalized() * line.width
	
	# Calculate fitting points
	var origin = to_global(position)
	var p1 = origin + w / 2
	var p2 = p1 + laser_vector
	var p3 = p2 - w
	var p4 = origin - w / 2
	
	# Create and update polygon
	var polygon = PackedVector2Array([
		to_local(p1),
		to_local(p2),
		to_local(p3),
		to_local(p4)
	])
	hitbox.polygon = polygon

func get_target_position(t_position: Vector2, is_shooting: bool) -> Vector2:
	# DO NOT CHANGE THE ROTATION!
	var angle = get_angle_to(t_position)
	if (is_shooting):
		curTargetAngle += clamp(angle_difference(curTargetAngle, angle), -1, 1) * RAY_ANGULAR_SPEED
	else:
		curTargetAngle = randf_range(-1, 1) * RAY_RETARGET_MAX_DEGREES + angle
	return to_global(Vector2(cos(curTargetAngle), sin(curTargetAngle)))

# Since there is only one player, we can assume no other entity will trigger the laser collision
func _on_laser_hitbox_body_entered(body: Node2D) -> void:
	EventBus.signal_damage.emit(body, RAY_DAMAGE)
