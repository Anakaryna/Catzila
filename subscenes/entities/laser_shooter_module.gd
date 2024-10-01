class_name LaserShooter

extends Node2D

const RAY_LENGTH = 9999

@export var target : Node2D

@onready var line : Line2D = $LaserGraphics
@onready var hitbox : CollisionPolygon2D = $LaserHitbox/LaserShape

var curTargetAngle = 0

func _ready() -> void:
	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)

func _physics_process(delta: float) -> void:
	# TODO: Track target better
	var curTargetPosition = target.position
	
	# Raycast for "infinite" ray
	var origin = position
	var end = origin + (curTargetPosition - origin).normalized() * RAY_LENGTH
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(origin, end, 0b010)
	var result = space_state.intersect_ray(query)
	
	# Draw result
	line.points[1] = to_local(result.position) if result.has("position") else to_local(end)
	
	update_hitbox(origin, end)

func update_hitbox(origin: Vector2, end: Vector2) -> void:
	# Get shape information
	var laser_vector = end - origin
	var w = Vector2(-laser_vector.y, laser_vector.x).normalized() * line.width
	
	# Calculate fitting points
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

func get_target_position(t_position: Vector2) -> Vector2:
	return Vector2.ZERO
