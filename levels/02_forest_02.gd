extends TileMapLayer

@export var bgm: AudioStream

func _on_levisterio_unlock_body_entered(_body: Node2D) -> void:
	if not Entities.player.unlocked_weapons.has(Entities.player.Weapons.LEVISTERIO):
		
		$ObtainItemSound.play()
		$Levisterio.visible = true
		var tween = get_tree().create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property($Levisterio, "offset", Vector2(0.0, 0.0), 0.5)
		
		await Entities.ui.open_dialog(
			tr("PROTAGONIST_DIALOG_3") % 
			InputMap.action_get_events("shoot")[0].as_text()
		)
		$Levisterio.visible = false
		Entities.player.unlock_weapon(Entities.player.Weapons.LEVISTERIO)
		Entities.player.set_process_unhandled_input(true)
		Entities.player.set_physics_process(true)
