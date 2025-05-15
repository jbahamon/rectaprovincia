extends MarginContainer

@onready var fade_fg: ColorRect = $ColorRect
@onready var label = $VBoxContainer/Label
@onready var retry = $VBoxContainer/HBoxContainer/Retry
func on_game_ended(win):
	self.set_mode(win)
	self.show()
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_method(self.tween_fade.bind(self), 0.0, 1.0, 1)
	
	if win:
		$VBoxContainer/HBoxContainer/Exit.grab_focus()
	else:
		retry.grab_focus()
	
func _on_retry_pressed() -> void:
	$UISound.play()
	await self.fade()
	SceneSwitcher.go_to_scene("res://main/world.tscn")

func _on_exit_pressed() -> void:
	$UISound.play()
	await self.fade()
	SceneSwitcher.go_to_scene("res://main/main_menu.tscn")

func fade():
	fade_fg.show()
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_method(self.tween_fade.bind(fade_fg), 0.0, 1.0, 1)
	await tween.finished
	
func tween_fade(fade_amount, canvas_item):
	var weight = clamp(round(fade_amount*8)/8, 0.0, 1.0)
	canvas_item.modulate = lerp(Constants.TRANSPARENT, Color.WHITE, weight)

func _on_button_focus() -> void:
	if self.visible:
		$UIFocusSound.play()

func set_mode(win: bool):
	if win:
		retry.hide()
		label.text = tr("WIN")
	else:
		retry.show()
		label.text = tr("GAME_OVER")
