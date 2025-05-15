extends TileMapLayer

@export var bgm: AudioStream

func _on_end_body_entered(_body: Node2D) -> void:
	Entities.player.set_process_unhandled_input(false)
	Entities.player.velocity.x = 0
	await Entities.ui.open_dialog(tr("END_1"))
	$Invunche/Roar.play()
	await $Invunche/Roar.finished
	$Invunche.visible = true

	
	Entities.player.create_circle_at($Invunche.global_position, 1.0, -1, Vector2.ZERO, true)
	await Entities.ui.open_dialog(tr("END_2"))
	Entities.world.end_game(true)
