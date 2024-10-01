class_name LaserCooldown

extends Node2D

@export var is_laser_cooldown_duration_random : bool
@export var min_laser_cooldown_duration : float
@export var max_laser_cooldown_duration : float
## If not random, set a duration cooldown for the laser
@export var laser_cooldown_duration : float

@export var is_laser_shoot_duration_random : bool
@export var min_laser_shoot_duration : float
@export var max_laser_shoot_duration : float
## If not random, set a duration shoot for the laser
@export var laser_shoot_duration : float

var is_shooting: bool = false

var cooldown_time_remaining: float
var laser_shoot_time_remaining: float

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_shooting = false
	
	cooldown_time_remaining = _set_laser_cooldown_duration()
	laser_shoot_time_remaining = _set_laser_shoot_duration()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if cooldown_time_remaining >= 0:
		is_shooting = false
		cooldown_time_remaining = cooldown_time_remaining - delta
		EventBus.is_laser_shooting.emit(false)
		
	elif cooldown_time_remaining < 0 and is_shooting == false:
		is_shooting = true
		laser_shoot_time_remaining = _set_laser_shoot_duration()
		EventBus.is_laser_shooting.emit(true)
		
	elif laser_shoot_time_remaining >= 0:
		is_shooting = true
		laser_shoot_time_remaining = laser_shoot_time_remaining - delta
		EventBus.is_laser_shooting.emit(true)
		
	elif laser_shoot_time_remaining < 0:
		is_shooting = false
		cooldown_time_remaining = _set_laser_cooldown_duration()
		EventBus.is_laser_shooting.emit(false)
		

func _set_laser_cooldown_duration() -> float:
	if is_laser_cooldown_duration_random:
		laser_cooldown_duration = rng.randf_range(min_laser_cooldown_duration, max_laser_cooldown_duration)
	
	return laser_cooldown_duration

func _set_laser_shoot_duration() -> float:
	if is_laser_shoot_duration_random:
			laser_shoot_duration = rng.randf_range(min_laser_shoot_duration, max_laser_shoot_duration)
		
	return laser_shoot_duration
