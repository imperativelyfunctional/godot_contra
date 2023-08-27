extends Area2D

func _on_body_entered(body):
	if body.get_class() == 'CharacterBody2D':
		EventBus.emit_signal('enter_water')


func _on_body_exited(body):
	if body.get_class() == 'CharacterBody2D':
		EventBus.emit_signal('exit_water')
