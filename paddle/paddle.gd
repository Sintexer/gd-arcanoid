class_name Paddle extends CharacterBody2D

const MAX_HIT_CHARGES := 3
const SPEED := 1500.0
const JUMP_VELOCITY := -400.0

@onready var superhit_skill: SuperhitSkill = $SuperhitSkill

var bounds : Vector2
var hit_stop: bool = false

var position_changing_velocity: Vector2 = Vector2.ZERO

var hit_charges: int = 0

@export var bounciness: float = 1.2

func _ready() -> void:
	bounds = get_viewport_rect().end
	Engine.time_scale = 1.0

func _physics_process(_delta: float) -> void:
	if hit_stop: return
	
	var origin: Vector2 = global_transform.origin
	var original_y: float = origin.y
	var targetPosition: Vector2 = get_global_mouse_position().clamp(Vector2.ZERO, bounds)
	targetPosition.y = origin.y
	global_transform.origin.x = targetPosition.x
	var distance: float = origin.distance_to(targetPosition)
	#
	if distance > 1:
		var progress: float = 1 - clampf((distance / 100), 0 , 1)
		var easing: float = 1.0 if distance > 100 else 1 - ease(progress, 2)
		if distance < 15:
			easing = 0

		velocity = origin.direction_to(targetPosition) * SPEED * easing
		move_and_slide()
		global_transform.origin.y = original_y

func _input(event):
	if (has_skill_charged() and event.is_action_pressed("use_skill")):
		superhit_skill.try_use()
		
func get_bounciness() -> float:
	return bounciness

func hit() -> void:
	$Bump.play()
	if hit_charges < MAX_HIT_CHARGES:
		hit_charges += 1
	print("Hit charges: " + str(hit_charges))
	if (has_skill_charged()):
		superhit_skill.enable()

func has_skill_charged() -> bool: return hit_charges == MAX_HIT_CHARGES

func _on_hit_stop_timeout() -> void:
	hit_stop = false


func _on_superhit_skill_used() -> void:
	$HitStop.start()
	hit_charges = 0
	superhit_skill.disable()


func _on_superhit_skill_aiming() -> void:
	hit_stop = true
