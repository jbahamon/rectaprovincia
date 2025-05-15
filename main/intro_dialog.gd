extends PanelContainer

signal closed

@onready var content = $HBoxContainer/Content
@onready var close_label = $HBoxContainer/Close
@onready var timer: Timer = $Timer

func _ready():
	self.set_process_unhandled_input(false)

func open(text: String):
	self.set_process_unhandled_input(false)
	self.close_label.modulate = Color(Color.WHITE, 0.0)
	self.close_label.text = "[%s]" % InputMap.action_get_events("ui_accept")[0].as_text()
	self.content.text = text
	self.show()
	self.timer.start()
	await timer.timeout
	self.close_label.modulate = Color.WHITE
	self.set_process_unhandled_input(true)
	await self.closed
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		self.close()
		get_viewport().set_input_as_handled()
		
func close():
	self.set_process_unhandled_input(false)
	self.hide()
	self.closed.emit()
