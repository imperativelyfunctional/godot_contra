extends Node


@onready var theme : AudioStreamPlayer2D = $Theme

func _ready():
	EventBus.connect('dead', Callable(self, '_stop_music'))

func _stop_music():
	theme.stop()
