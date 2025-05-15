extends Area2D

func _on_body_entered(_body: Node2D) -> void:
	Entities.player.heal_sound.play()
	Entities.player.hp = clamp(Entities.player.hp + 10, 0, Entities.player.max_hp)
	Entities.ui.update()
	self.queue_free()
