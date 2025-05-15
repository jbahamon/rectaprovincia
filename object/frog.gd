extends AnimatedSprite2D

@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var on_screen = false

func _on_animation_looped() -> void:
	var facing = -1 if flip_h else 1
	Entities.create_echo_at(self.position + Vector2(3 * facing , 1))

	audio_stream_player.play()
