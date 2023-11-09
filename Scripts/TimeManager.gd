extends Node

const phase_multiplier = 2
var time_left = 120.0
var active = false

@export var Player : CharacterBody2D


func _ready():
	active = true


func _physics_process(delta):
	if active:
		match Player.body_state:
			Player.body_states.SOLID:
				remove_time(delta)
			Player.body_states.PHASE:
				remove_time(delta * phase_multiplier)


func add_time(amount):
	time_left += amount

func remove_time(amount):
	time_left -= amount


func timeout():
	Player.die()
