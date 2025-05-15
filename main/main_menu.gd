extends CanvasLayer

@onready var start: Button = $MarginContainer/MainContainer/MainMenu/OptionsContainer/Options/Start

@onready var help_label: Label = $MarginContainer/MainContainer/HelpBar/HelpText
@onready var controls_help: Label = $MarginContainer/MainContainer/HelpBar/ControlsText
@onready var main_menu: Control = $MarginContainer/MainContainer/MainMenu
@onready var credits: Control = $MarginContainer/MainContainer/Credits

@onready var fade_fg: ColorRect = $ColorRect

func _ready() -> void:
	var preferred_language = OS.get_locale_language()
	TranslationServer.set_locale(preferred_language)
	get_tree().paused = true
	self.on_main_menu()
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_method(self.fade, 1.0, 0.0, 1)
	await tween.finished
	fade_fg.hide()
	get_tree().paused = false

func on_main_menu():
	start.grab_focus()
	controls_help.text = tr("MAIN_MENU_CONTROLS") % [
		InputMap.action_get_events("ui_up")[0].as_text(),
		InputMap.action_get_events("ui_down")[0].as_text(),
		InputMap.action_get_events("ui_accept")[0].as_text()
	]
func _on_start_pressed() -> void:
	$UISound.play()
	get_viewport().gui_get_focus_owner().release_focus()
	get_tree().paused = true
	fade_fg.show()
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade_fg, "modulate", Color.WHITE, 1)
	tween.tween_property($AudioStreamPlayer, "volume_linear", 0, 1)
	await tween.finished

	SceneSwitcher.go_to_scene("res://main/intro.tscn")

func _on_credits_pressed() -> void:
	$UISound.play()
	main_menu.hide()
	credits.show_menu()
	help_label.text = ""
	controls_help.text = tr("CREDITS_CONTROLS") % [
		InputMap.action_get_events("ui_up")[0].as_text(),
		InputMap.action_get_events("ui_down")[0].as_text(),
		InputMap.action_get_events("ui_cancel")[0].as_text()
	]

func _on_exit_pressed() -> void:
	$UISound.play()
	get_tree().quit()

func _on_start_focus_entered() -> void:
	help_label.text = tr("START_HELP")

func _on_credits_focus_entered() -> void:
	help_label.text = tr("CREDITS_HELP")

func _on_exit_focus_entered() -> void:
	help_label.text = tr("EXIT_HELP")

func _on_credits_exit() -> void:
	$UISound.play()
	credits.hide_menu()
	main_menu.show()
	self.on_main_menu()
	
func fade(fade_amount):
	var weight = clamp(round(fade_amount*8)/8, 0.0, 1.0)
	fade_fg.modulate = lerp(Constants.TRANSPARENT, Color.WHITE, weight)
