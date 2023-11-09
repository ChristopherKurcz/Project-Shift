extends Control

# Child Nodes
@onready var TimeLeftLabel = $MarginContainer/VBoxContainer/HBoxContainer/TimeLeftLabel
# External Nodes
@export var TimeManager : Node

func _process(_delta):
	TimeLeftLabel.text = str("%3.1f" % TimeManager.time_left)
