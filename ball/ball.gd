extends CharacterBody2D

const MIN_SPEED = 700.0
const MIN_X_SPEED = 100.0
const MIN_Y_SPEED = 700.0

const MAX_SPEED = 1000.0
const MAX_X_SPEED = 1000.0
const MAX_Y_SPEED = 1000.0
const MAX_Y_BOUNCE_SPEED = 2000.0

const MAX_PADDLE_COLLISION_SPEED = 2000.0
const MAX_CURVE_SPEED = 100.0

const CURVE_CONDFITION_VELOCITY = 100.0;

@onready var min_abs_speed: Vector2 = Vector2(MIN_X_SPEED, MIN_Y_SPEED)
@onready var max_abs_speed: Vector2 = Vector2(MAX_X_SPEED, MAX_Y_SPEED)
@onready var max_abs_bounced_speed: Vector2 = Vector2(MAX_X_SPEED, MAX_Y_BOUNCE_SPEED)

@export var gravity_multiplier: float = 1
@export var collision_damping: float = 0.8
@export var curving_step: float = 0.3

var last_collision_frame: int = -1

var curving: bool = false
var curveball_velocity: Vector2 = Vector2.ZERO

func _ready():
	velocity.y += MIN_SPEED
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta
	if curving:
		velocity += curving_step * curveball_velocity
		
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision: 
		process_collision(collision)

func process_collision(collision: KinematicCollision2D) -> void:
	if (curving): stop_curving()
	
	bounce(collision)
	if collision.get_collider() is Paddle:
		handle_moving_collision(collision, collision.get_collider())

func bounce(collision: KinematicCollision2D) -> void: 
	var normal = collision.get_normal()
	velocity = velocity.bounce(normal)
	var direction: Vector2 = Vector2(sign(velocity.x), sign(velocity.y))
	var max_speed: Vector2 = max_abs_speed
	if collision.get_collider().has_method("get_bounciness"):
		velocity *= collision.get_collider().get_bounciness()
		max_speed = max_abs_bounced_speed
	else:
		velocity *= collision_damping
	velocity = direction * velocity.abs().clamp(min_abs_speed, max_speed)
	print(velocity)
	
func handle_moving_collision(collision: KinematicCollision2D, paddle: Paddle) -> void:
	var vel = collision.get_normal().orthogonal().abs() * paddle.get_velocity()
	if (vel.length() > CURVE_CONDFITION_VELOCITY):
		init_curving(vel)
		
		
func init_curving(curving_velocity: Vector2) -> void:
	curveball_velocity.aspect()

	curving = true
	curveball_velocity = curving_velocity.clampf(-MAX_CURVE_SPEED, MAX_CURVE_SPEED)
	print("Curving=" + str(curveball_velocity))
	$CurvingTimer.start()


func _on_curving_timer_timeout() -> void:
	stop_curving()
	
func stop_curving() -> void:
	$CurvingTimer.stop()
	curving = false
