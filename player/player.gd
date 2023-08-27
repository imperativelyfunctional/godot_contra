extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -450.0
const JUMP_VELOCITY_IN_WATER = -200.0

var gravity = ProjectSettings.get_setting('physics/2d/default_gravity')

@onready var playback : AnimationNodeStateMachinePlayback = $AnimationTree['parameters/playback']
@onready var sprite : Sprite2D = $Sprite2D
@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var death : AudioStreamPlayer2D = $Death
@onready var end : AudioStreamPlayer2D = $End

var touch_water : bool = false
var dead : bool = false

const animation_map = {
	'11': {'animation': 'down_walking', 'position': Vector2(30, 10), 'direction': Vector2(1, 0.7)},
	'1-1': {'animation': 'up_walking', 'position': Vector2(28, -45), 'direction': Vector2(1, -0.8)},
	'10': {'animation': 'walking', 'position': Vector2(35, -10), 'direction': Vector2(1, 0)},
	'-11': {'animation': 'down_walking', 'position': Vector2(-30, 10), 'direction': Vector2(-1, 0.7)},
	'-1-1': {'animation': 'up_walking', 'position': Vector2(-28, -45), 'direction': Vector2(-1, -0.8)},
	'-10': {'animation': 'walking', 'position': Vector2(-35, -10), 'direction': Vector2(-1, 0)},
	'011': {'animation': 'down', 'position': Vector2(40, 22), 'direction': Vector2(1, 0)},
	'01-1': {'animation': 'down', 'position': Vector2(-40, 22), 'direction': Vector2(-1, 0)},
	'0-11': {'animation': 'up_shooting', 'position': Vector2(0, -70), 'direction': Vector2(0, -1)},
	'0-1-1': {'animation': 'up_shooting', 'position': Vector2(0, -70), 'direction': Vector2(0, -1)},
	'001': {'animation': 'standing', 'position': Vector2(35, -10), 'direction': Vector2(1, 0)},
	'00-1': {'animation': 'standing', 'position': Vector2(-35, -10), 'direction': Vector2(-1, 0)},
	'2001': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(1, 0)},
	'210': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(1, 0)},
	'2-10': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(-1, 0)},
	'200-1': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(-1, 0)},
	'2100': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(1, 0)},
	'2-100': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(-1, 0)},
	'2011': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(0, 1)},
	'2-1-10': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(-1, -1)},
	'201-1': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(1, 0 )},
	'21-10': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(1, -1)},
	'2-1-1': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(-1, -1)},
	'21-1': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(1, -1)},
	'2-11': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(-1, 1)},
	'211': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(1, 1)},
	'2110': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(1, 1)},
	'20-11': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(0, -1)},
	'20-110': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(0, -1)},
	'20-1-1': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(0, -1)},
	'20-1-10': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(0, -1)},
	'2-110': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(-1, 1)},
	'200-10': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(-1, 0)},
	'20010': {'animation': 'jumping', 'position': Vector2.ZERO, 'direction': Vector2(1, 0)},
	'110': {'animation': 'down_in_water', 'position': Vector2.ZERO, 'direction': Vector2.ZERO},
	'1-10': {'animation': 'up_walking_in_water', 'position': Vector2(20, 0), 'direction': Vector2(1, -1)},
	'100': {'animation': 'walking_in_water', 'position': Vector2(30, 30), 'direction': Vector2(1, 0)},
	'-110': {'animation': 'down_in_water', 'position': Vector2.ZERO, 'direction': Vector2.ZERO},
	'-1-10': {'animation': 'up_walking_in_water', 'position': Vector2(-20, 0), 'direction': Vector2(-1, -1)},
	'-100': {'animation': 'walking_in_water', 'position': Vector2(-30, 30), 'direction': Vector2(-1, 0)},
	'0110': {'animation': 'down_in_water', 'position': Vector2.ZERO, 'direction': Vector2.ZERO},
	'01-10': {'animation': 'down_in_water', 'position': Vector2.ZERO, 'direction': Vector2.ZERO},
	'0-110': {'animation': 'up_shooting_in_water', 'position': Vector2(12, -25), 'direction': Vector2(0, -1)},
	'0-1-10': {'animation': 'up_shooting_in_water', 'position': Vector2(-12, -25), 'direction': Vector2(0, -1)},
	'0010': {'animation': 'walking_in_water', 'position': Vector2(30, 30), 'direction': Vector2(1, 0)},
	'00-10': {'animation': 'walking_in_water', 'position': Vector2(-30, 30), 'direction': Vector2(-1, 0)},
}

func _ready():
	EventBus.connect('enter_water', func(): touch_water = true)
	EventBus.connect('exit_water', func(): touch_water = false)
	EventBus.connect('dead', Callable(self, '_dead'))
	
func _dead():
	dead = true
	playback.travel('dead')
	EventBus.emit_signal('stop_shooting')
	death.play()
	death.connect("finished", func() : end.play())
	
func _physics_process(delta):
	if !dead:
		if not is_on_floor():
			velocity.y += gravity * delta
		
		var x_direction = Input.get_axis('ui_left', 'ui_right')
		var y_direction = Input.get_axis('ui_up', 'ui_down')
		
		if Input.is_action_pressed('ui_accept') and is_on_floor() && (y_direction != 1 || (y_direction && x_direction != 0)) :
			if touch_water:
				velocity.y = JUMP_VELOCITY_IN_WATER
			else:
				velocity.y = JUMP_VELOCITY
		
		if y_direction == 1 && is_on_floor() && Input.is_action_pressed('ui_accept') && x_direction == 0:
			collision_shape.disabled = true
			var timer = Timer.new()
			timer.wait_time = 0.1
			timer.one_shot = true
			timer.autostart = true
			timer.connect('timeout', Callable(func(): collision_shape.disabled = false))
			add_child(timer)

		var key = str(x_direction) + str(y_direction)
		if key.begins_with("0"):
			key = (key + '-1') if sprite.flip_h else key + '1'
		if touch_water:
			key += '0'
		if !is_on_floor():
			key = '2' + key
		playback.travel(animation_map[key]['animation'])
		
		if x_direction == 1:
			sprite.flip_h = false
		elif x_direction == -1:
			sprite.flip_h = true
				
		if x_direction && animation_map[key]['animation'] != 'down_in_water':
			velocity.x = x_direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()

		if Input.is_action_pressed("ui_shoot"):
			EventBus.emit_signal('shooting', position + animation_map[key]['position'], animation_map[key]['direction'].normalized())
		elif Input.is_action_just_released("ui_shoot"):
			EventBus.emit_signal('stop_shooting')
