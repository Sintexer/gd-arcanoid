class_name SuperhitSkill extends Node2D

signal aiming
signal used

@onready var arrow := $Arrow
@onready var zone := $Zone
@onready var area := $Area

var active: bool = false
var aim: bool = false
var ball_in_zone: Node2D = null

func _ready() -> void:
	disable()
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func enable():
	active = true
	visible = true
	aim = false
	zone.visible = true
	arrow.visible = false
	
func disable():
	active = false
	visible = false
	aim = false
	zone.visible = false
	arrow.visible = false
	
func try_use():
	if ball_in_zone:
		start_aiming()

func start_aiming():
	aim = true
	#Engine.time_scale = 0.0
	#print("stop time: " + str(Engine.time_scale))
	ball_in_zone.stop()
	aiming.emit()
	arrow.visible = true
	ball_in_zone.global_position = global_position + Vector2(0, -32)
		
func _process(_delta: float) -> void:
	if !active or !aiming: return
	arrow.look_at(get_global_mouse_position())
	if Input.is_action_just_released("use_skill") and ball_in_zone:
		fire()

func fire():
	print("launching")
	var direction = (get_global_mouse_position() - global_position).normalized()
	disable()
	if ball_in_zone and ball_in_zone.has_method("launch"):
		ball_in_zone.launch(direction * 1000)
	#Engine.time_scale = 1.0
	used.emit()

func _on_body_entered(body):
	if body.is_in_group("Ball"):
		ball_in_zone = body

func _on_body_exited(body):
	if body == ball_in_zone:
		ball_in_zone = null
