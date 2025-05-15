extends Node2D

@onready var ui_layer = $CanvasLayer
@onready var transition_color: ColorRect = $CanvasLayer/ColorRect
@onready var bgm: AudioStreamPlayer = $BGM
@onready var ui_sound: AudioStreamPlayer = $UISound
@onready var game_ended_ui: Control = $CanvasLayer/GameEndedUI

func _ready() -> void:
	Entities.initialize(self, $Player, $CanvasLayer/UI)
	Entities.ui.update()
	await self.switch_level("01_house", Vector2(80, 16))
	

func switch_level(level_name: String, target_position: Vector2):
	
	get_tree().paused = true
	
	var current_level = self.get_node_or_null("Level")
	
	if current_level != null:
		$TransitionSound.play()
		var out_tween = get_tree().create_tween()
		out_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		out_tween.tween_method(self.fade, 0.0, 1.0, 0.3)
		await out_tween.finished
		
		self.remove_child(current_level)
		current_level.queue_free()
	else:
		Entities.player.set_process_unhandled_input(false)
		Entities.player.set_physics_process(false)
	Entities.player.clear_vision()
	var new_level: TileMapLayer = load("res://levels/%s.tscn" % level_name).instantiate()
	self.add_child(new_level)
	self.move_child(new_level, 0)
	Entities.player.position = target_position
	var bounds = new_level.get_used_rect()
	
	Entities.camera.limit_top = bounds.position.y * 8
	Entities.camera.limit_bottom = bounds.end.y * 8
	Entities.camera.limit_left = bounds.position.x * 8
	Entities.camera.limit_right = bounds.end.x * 8
	
	Entities.camera.align()
	
	if bgm.stream != new_level.bgm:
		bgm.stream = new_level.bgm
		if bgm.stream != null:
			bgm.play()
		else:
			bgm.stop()
	
	var in_tween = get_tree().create_tween()
	in_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	in_tween.tween_method(self.fade, 1.0, 0.0, 0.3 if current_level != null else 1.3)
	await in_tween.finished
	Entities.player.was_on_floor = true
	get_tree().paused = false
	if "on_enter" in new_level:
		new_level.on_enter()
	
func fade(fade_amount):
	var weight = clamp(round(fade_amount*8)/8, 0.0, 1.0)
	self.transition_color.modulate = lerp(Constants.TRANSPARENT, Color.WHITE, weight)
	
func end_game(win: bool):
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(bgm, "volume_linear", 0, 1)
	get_tree().paused = true
	self.game_ended_ui.on_game_ended(win)
	
		
