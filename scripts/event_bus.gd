extends Node

signal level_started
signal level_ended
signal player_was_hit
signal connectivity_changed(online: bool)
signal signal_damage(body: CharacterBody2D, damagePoints: float)
signal handicap(body: CharacterBody2D)

signal is_laser_shooting(is_shooting: bool, timer_percentage: float)
signal is_catzila_cloning(is_cloned: bool, timer: float)
