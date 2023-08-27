extends Timer

var bullet = preload("res://bullet/Bullet.tscn")

var can_shoot : bool = false
var position : Vector2
var direction : Vector2
@onready var gun_shot : AudioStreamPlayer2D = $"../GunShot"
 
func _ready():
	EventBus.connect('shooting', Callable(self, '_enable_shooting'))
	EventBus.connect('stop_shooting', func(): can_shoot = false)

func _enable_shooting(bullet_position, bullet_direction):
	can_shoot = true
	position = bullet_position
	direction = bullet_direction
	
func _on_timeout():
	if can_shoot && direction != Vector2.ZERO:
		if !gun_shot.playing:
			gun_shot.play()
		var b : Bullet = bullet.instantiate()
		b.speed = 1000
		b.position = position
		b.direction = direction
		get_tree().root.add_child(b)
