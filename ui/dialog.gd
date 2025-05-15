extends PanelContainer

signal closed

@onready var content = $HBoxContainer/Content
@onready var close_label = $HBoxContainer/Close
@onready var timer: Timer = $Timer

var was_player_processing = true

func _ready():
	self.set_process_unhandled_input(false)

func open(text: String):
	self.close_label.modulate = Color(Color.WHITE, 0.0)
	self.close_label.text = "[%s]" % InputMap.action_get_events("ui_accept")[0].as_text()
	get_tree().paused = true
	
	self.was_player_processing = Entities.player.is_processing_unhandled_input()
	
	Entities.player.set_process_unhandled_input(false)
	Entities.player.set_physics_process(false)
	
	self.content.text = text
	self.show()
	self.timer.start()
	await timer.timeout
	self.close_label.modulate = Color.WHITE
	self.set_process_unhandled_input(true)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		self.close()
		get_viewport().set_input_as_handled()
		
func close():
	Entities.world.ui_sound.play()
	self.set_process_unhandled_input(false)
	self.hide()
	get_tree().paused = false
	if self.was_player_processing:
		Entities.player.set_process_unhandled_input(true)
		Entities.player.set_physics_process(true)
	self.closed.emit()
