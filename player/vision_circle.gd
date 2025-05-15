extends Sprite2D

signal finished

var is_anchored = false
var anchor_position: Vector2
var velocity: Vector2

var duration: float = 1.0
var size: float = 1.0

func _ready() -> void:
	var tween = self.get_tree().create_tween()

	if self.process_mode == ProcessMode.PROCESS_MODE_ALWAYS:
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "scale", Vector2(size, size), 0.1)
	await tween.finished
	
	if self.is_queued_for_deletion():
		return
		
	if duration > 0:
		await self.get_tree().create_timer(2.0 * duration).timeout
		self.velocity = Vector2.ZERO
		
		if self.is_queued_for_deletion():
			return

		tween = self.get_tree().create_tween()
		tween.tween_property(self, "scale", Vector2(0.01, 0.01), 0.8)
		
		await tween.finished
		
		if self.is_queued_for_deletion():
			return
			
		self.finished.emit()
		self.queue_free()
	else:
		self.velocity = Vector2.ZERO
		
func anchor(position_to_anchor):
	self.is_anchored = true
	self.anchor_position = position_to_anchor
	
func _process(delta: float) -> void:
	if self.is_anchored:
		self.anchor_position += delta * velocity 
		self.global_position = self.anchor_position
		
