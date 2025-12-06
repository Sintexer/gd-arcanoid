extends CharacterBody2D

@export var speed: int = 30
var half_size: float
var screen_width: float

func _ready() -> void:
	half_size = $CollisionShape2D.get_shape().get_rect().size.y / 2
	print(half_size)

func _physics_process(_delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed
	move_and_slide()
