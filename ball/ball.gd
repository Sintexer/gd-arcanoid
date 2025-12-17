extends CharacterBody2D

const MIN_X_SPEED = 50
const MIN_Y_SPEED = 350

const MAX_X_SPEED = 1000.0 
const MAX_Y_SPEED = 1000.0

const MAX_CURVE_SPEED = 50

const CURVE_CONDFITION_VELOCITY = 10

const MIN_SPEED: Vector2 = Vector2(MIN_X_SPEED, MIN_Y_SPEED)

@export var max_speed_length: float = 1800.0

@export var gravity_multiplier: float = 1
@export var collision_damping: float = 0.8
@export var curving_step: float = 0.3
@export var mass: float = 1
@export var impulse_saved_bounce_threshold: float = 0.8

var curving: bool = false
var curveball_velocity: Vector2 = Vector2.ZERO

var frozen: bool = false

func _ready():
	velocity.y += MIN_Y_SPEED

func _physics_process(delta: float) -> void:
	if frozen: return
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta
	if curving:
		velocity += curving_step * curveball_velocity
		
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision: 
		process_collision(collision)
	clamp_velocity()

func process_collision(collision: KinematicCollision2D) -> void:
	if (curving): stop_curving()
	
	$Hit.play()
	if collision.get_collider() is Paddle:
		handle_moving_collision(collision, collision.get_collider())
	elif (collision.get_collider() is Brick):
		handle_inerting_collision(collision, collision.get_collider())
	else:
		bounce(collision)

func handle_moving_collision(collision: KinematicCollision2D, paddle: Paddle) -> void:
	var vel = collision.get_normal().orthogonal().abs() * paddle.get_velocity()
	paddle.hit()
	if (vel.length() > CURVE_CONDFITION_VELOCITY):
		init_curving(vel)
	bounce(collision)
		
func handle_inerting_collision(collision: KinematicCollision2D, brick: Brick) -> void:
	var impulse_saved = brick.handle_hit(velocity * mass)
	if impulse_saved == 1:
		bounce(collision)
	else:
		velocity *= impulse_saved
		
func init_curving(curving_velocity: Vector2) -> void:
	curveball_velocity.aspect()

	$Curve.play()
	curving = true
	curveball_velocity = curving_velocity.clampf(-MAX_CURVE_SPEED, MAX_CURVE_SPEED)
	$CurvingTimer.start()

func bounce(collision: KinematicCollision2D) -> void: 
	var normal = collision.get_normal()
	velocity = velocity.bounce(normal)
	if collision.get_collider().has_method("get_bounciness"):
		velocity *= collision.get_collider().get_bounciness()
	else:
		velocity *= collision_damping
	
func clamp_velocity():
	var direction: Vector2 = Vector2(sign(velocity.x), sign(velocity.y))
	if absf(velocity.x) < MIN_X_SPEED:
		velocity.x = direction.x * MIN_X_SPEED
	if absf(velocity.y) < MIN_Y_SPEED:
		velocity.y = direction.y * MIN_Y_SPEED
	velocity = velocity.limit_length(max_speed_length)

func _on_curving_timer_timeout() -> void:
	stop_curving()
	
func stop_curving() -> void:
	$CurvingTimer.stop()
	curving = false

func stop() -> void:
	velocity = Vector2.ZERO
	frozen = true

func launch(launch_velocity: Vector2):
	frozen = false
	stop_curving()
	velocity = launch_velocity
