extends Area2D

const time_per_pickup = 1.0

@onready var self_AnimationPlayer = $AnimationPlayer

@export var TimeManger : Node


func _on_body_entered(body):
	if body.is_in_group("Player"):
		TimeManger.add_time(time_per_pickup)
		collected()


func collected():
	set_deferred("monitorable",false)
	set_deferred("monitoring",false)
	self_AnimationPlayer.play("collected")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "collected":
		queue_free()
