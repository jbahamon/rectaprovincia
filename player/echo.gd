extends AnimatedSprite2D

var is_anchored = false
var anchor_position: Vector2

func _ready() -> void:
	self.visible = false
	await self.animation_finished
	if not self.is_queued_for_deletion():
		self.queue_free()

func anchor(position_to_anchor):
	self.is_anchored = true
	self.anchor_position = position_to_anchor
	self.global_position = self.anchor_position
	self.visible = true
	
func _process(_delta: float) -> void:
	if self.is_anchored:
		self.global_position = self.anchor_position
		
