extends TileMapLayer

@export var bgm: AudioStream
signal player_hit_floor
@onready var controls_label: Label = $ControlsLabel

func _ready():
	self.set_process(false)
	
func on_enter():
	if not Entities.player.challanco_unlocked:
		Entities.player.set_process_unhandled_input(false)
		Entities.player.set_physics_process(false)
		await get_tree().create_timer(0.3).timeout
		await Entities.ui.open_dialog(tr("PROTAGONIST_DIALOG_1"))
		
		var left = InputMap.action_get_events("move_left")[0].as_text()
		var right = InputMap.action_get_events("move_right")[0].as_text()
		var jump = InputMap.action_get_events("jump")[0].as_text()
		
		controls_label.text = tr(controls_label.text) % [left, right, jump]		
		var tween = get_tree().create_tween()
		tween.tween_property(controls_label, "modulate", Color.WHITE, 0.2)
		await tween.finished
		Entities.player.set_physics_process(true)
		Entities.player.set_process_unhandled_input(true)
		
func _process(_delta: float) -> void:
	if Entities.player.is_on_floor():
		self.player_hit_floor.emit()
		
func _on_get_challanco_body_entered(_body: Node2D) -> void:
	if not Entities.player.challanco_unlocked:
		self.set_process(true)
		Entities.player.set_process_unhandled_input(false)
		await player_hit_floor
		await get_tree().physics_frame
		Entities.player.play_anim("idle")
		self.set_process(false)
		
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CIRC)
		$Challanco.visible = true
		$ObtainItemSound.play()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property($Challanco, "offset", Vector2(0.0, 0.0), 0.5)
		
		await Entities.ui.open_dialog(
			tr("PROTAGONIST_DIALOG_2") % 
			InputMap.action_get_events("challanco")[0].as_text()
		)
		$Challanco.visible = false
		Entities.player.challanco_unlocked = true
		Entities.ui.update()
		Entities.player.set_process_unhandled_input(true)
		Entities.player.set_physics_process(true)
