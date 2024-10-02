class_name CatCloning

extends Node2D

@export var maximum_number_of_cloned_cat : float
@export var original_cat : Node2D

var current_total_cloned_cat: float = 0

var cloned_cat : Node2D

@onready var laser_cat_scn = preload("res://subscenes/entities/laser_cat.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_total_cloned_cat = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	EventBus.is_catzila_cloning.connect(func(is_cloned: bool, timer: float):
		if is_cloned == false && timer <= 0.1:
			if cloned_cat == null: # TODO: Refactor to use an array of cloned cats
				if current_total_cloned_cat < maximum_number_of_cloned_cat:
					cloned_cat = laser_cat_scn.instantiate()
					cloned_cat.z_index = 1
					self.add_child(cloned_cat)
					cloned_cat.position = original_cat.position - (Vector2.DOWN * 300)
					current_total_cloned_cat += 1
					print("Created cloned cat")
		else:
			if timer <= 0.1 and cloned_cat != null:
				cloned_cat.queue_free()
				cloned_cat = null
				current_total_cloned_cat -= 1
				print("Destoyed cloned cat")
			)
