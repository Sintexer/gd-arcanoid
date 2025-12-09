class_name Brick extends StaticBody2D

const POWER_TO_HP: float = 3.0

@export var max_hp: float = 200

var hp: float
var dead: bool = false

func _ready() -> void:
	$Animation.play("default")
	hp = max_hp

## Returns percentage (float 0..1) of how much of the impulse should be left after hit
func handle_hit(hit_impulse: Vector2) -> float:
	var power: float = hit_impulse.length()
	#print("hit_impulse_length=" + str(power))
	var damage = power / POWER_TO_HP
	#print("gamage=" + str(damage))
	if (damage > hp):
		#print("hp="+ str(hp))
		die()
		return clampf(1 - hp/damage, 0.001, 1)
	else:
		hp -= damage
		#print("left hp="+ str(hp))
		return 1 ## do not slow the ball on hit

func die() -> void:
	
	$Animation.play("dead")
	$CollisionShape2D.disabled = true
	dead = true

func _on_sprite_2d_animation_finished() -> void:
	if dead: queue_free()
