class_name Paddle extends CharacterBody2D


const SPEED = 1500.0
const JUMP_VELOCITY = -400.0

var bounds : Vector2
var hit_stop: bool = false

var position_changing_velocity: Vector2 = Vector2.ZERO

@export var bounciness: float = 1.2

func _ready() -> void:
	bounds = get_viewport_rect().end

func _physics_process(delta: float) -> void:
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
#
		#
		velocity = origin.direction_to(targetPosition) * SPEED * easing
		move_and_slide()
		global_transform.origin.y = original_y
		#if collision != null and collision.get_collider().has_method("handle_collision"):
			#collision.get_collider().handle_collision(velocity, collision.get_normal())
			#hit()
func get_bounciness() -> float:
	return bounciness
	
#func get_self_velocity() -> Vector2: 
	#return velocity

func hit() -> void:
	pass
	#if hit_stop: return
	#hit_stop = true
	#$HitStop.start()

func _on_hit_stop_timeout() -> void:
	hit_stop = false
