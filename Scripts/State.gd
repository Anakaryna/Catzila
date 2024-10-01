extends Node

class_name State

signal Transitioned(state: State, new_state_name: String)

func Enter():
	pass
	
func Exit():
	pass
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	pass
