extends Node2D

@onready var cave: Sprite2D  = $Cave
@onready var gavel: Sprite2D  = $Gavel
@onready var inside_house: Sprite2D  = $InsideHouse
@onready var outside_house: Sprite2D  = $OutsideHouse

@onready var dialog: Control  = $CanvasLayer/VBoxContainer/Dialog
@onready var fade_fg: ColorRect = $ColorRect
@onready var ui_sound: AudioStreamPlayer = $UISound

func _ready() -> void:
	get_tree().paused = false
	var tween = get_tree().create_tween()
	tween.tween_method(self.fade, 0.0, 1.0, 0.4)
	await tween.finished
	self.fade_fg.hide()
	
	await dialog.open(tr("INTRO_1"))
	ui_sound.play()
	
	await self.slide_pic(cave)
	
	await dialog.open(tr("INTRO_2"))
	ui_sound.play()
	
	await self.slide_pic(gavel)
	
	await dialog.open(tr("INTRO_3"))
	ui_sound.play()
	
	await dialog.open(tr("INTRO_4"))
	ui_sound.play()
	
	await self.slide_pic(outside_house)

	await get_tree().create_timer(0.7).timeout
	await self.slide_pic(inside_house)

	await dialog.open(tr("INTRO_5"))
	ui_sound.play()
		
	fade_fg.modulate = Color.WHITE
	fade_fg.visible = true
	$CutSound.play()
	await get_tree().create_timer(0.5).timeout
	
	await dialog.open(tr("INTRO_6"))
	ui_sound.play()
	
	tween = get_tree().create_tween()
	tween.tween_property($AudioStreamPlayer, "volume_linear", 0, 1)
	await tween.finished
	SceneSwitcher.go_to_scene("res://main/world.tscn")
	
func slide_pic(pic: Sprite2D):
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(pic, "offset", Vector2(0 , 0), 0.5)
	return tween.finished

func _on_dialog_closed() -> void:
	ui_sound.play()

func fade(fade_amount):
	var weight = clamp(round(fade_amount*8)/8, 0.0, 1.0)
	fade_fg.modulate = lerp(Constants.TRANSPARENT, Color.WHITE, weight)
