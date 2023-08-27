extends Area2D


func _on_body_entered(_body):
	print('enter water')
	EventBus.emit_signal('enter_water')

func _on_body_exited(_body):
	print('exit water')
	EventBus.emit_signal('exit_water')
