class_name ScoreReward extends Node

const MIN_POINTS: int = 10

signal scored

var points: int = 0

func _ready() -> void:
	$Label.visible = false
	
func update(points_diff: int) -> void: points = max(MIN_POINTS, points + points_diff)

# TODO animate label fading over time

func activate():
	EventBus.score_updated.emit(points)
	$Label.text = str(points)
	$Label.visible = true
	scored.emit(points)

func _on_desctruction_timer_timeout() -> void:
	$Label.visible = false
	queue_free()
