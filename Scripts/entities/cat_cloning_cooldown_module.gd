## This class is a copy of laser_cooldown_module due to lack of time. 
## We should refactor laser_cooldown_module.gd to make it more generic instead of duplicating the same feature. 
## Because we need to present the project in less than 30 minutes, we are doing it this way for the moment.
class_name CatCloningCooldown

extends Node2D

@export var is_cat_cloning_cooldown_duration_random : bool
@export var min_cat_cloning_cooldown_duration : float
@export var max_cat_cloning_cooldown_duration : float
## If not random, set a duration cooldown for the cat cloning feature
@export var cat_cloning_cooldown_duration : float

@export var is_cloned_cat_duration_random : bool
@export var min_cloned_cat_duration : float
@export var max_cloned_cat_duration : float
## If not random, set a duration shoot for the cloned cat 
@export var cloned_cat_duration : float

var is_cloned: bool = false

var cooldown_time_remaining: float
var cloned_cat_time_remaining: float

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_cloned = false
	
	cooldown_time_remaining = _set_cat_cloning_cooldown_duration()
	cloned_cat_time_remaining = _set_cloned_cat_duration()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if cooldown_time_remaining >= 0:
		is_cloned = false
		cooldown_time_remaining = cooldown_time_remaining - delta
		EventBus.is_catzila_cloning.emit(false, cooldown_time_remaining)
		
	elif cooldown_time_remaining < 0 and is_cloned == false:
		is_cloned = true
		cloned_cat_time_remaining = _set_cloned_cat_duration()
		EventBus.is_catzila_cloning.emit(true, cloned_cat_time_remaining)
		
	elif cloned_cat_time_remaining >= 0:
		is_cloned = true
		cloned_cat_time_remaining = cloned_cat_time_remaining - delta
		EventBus.is_catzila_cloning.emit(true, cloned_cat_time_remaining)
		
	elif cloned_cat_time_remaining < 0:
		is_cloned = false
		cooldown_time_remaining = _set_cat_cloning_cooldown_duration()
		EventBus.is_catzila_cloning.emit(false, cooldown_time_remaining)
		

func _set_cat_cloning_cooldown_duration() -> float:
	if is_cat_cloning_cooldown_duration_random:
		cat_cloning_cooldown_duration = rng.randf_range(min_cat_cloning_cooldown_duration, max_cat_cloning_cooldown_duration)
	
	return cat_cloning_cooldown_duration

func _set_cloned_cat_duration() -> float:
	if is_cloned_cat_duration_random:
		cloned_cat_duration = rng.randf_range(min_cloned_cat_duration, max_cloned_cat_duration)
		
	return cloned_cat_duration
