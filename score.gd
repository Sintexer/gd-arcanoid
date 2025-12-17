extends Label

var total_score: int = 0
var active_score: int = 0
var multiplier: int = 0

func _ready() -> void:
	text = ""
	
func update_score(score_diff: int):
	active_score = max(0, active_score + score_diff)
	update_visual()

func update_visual():
	text = str(active_score)

func _on_tree_entered() -> void:
	EventBus.score_updated.connect(update_score)

func _on_tree_exited() -> void:
	EventBus.score_updated.disconnect(update_score)
