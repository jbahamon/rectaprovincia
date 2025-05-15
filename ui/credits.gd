extends MarginContainer

signal exit

var CreditsEntry = preload("res://ui/credits_entry.tscn")
const SCROLL_STEP = 50

@onready var containers = {
	"graphics": $ScrollContainer/VBox/Graphics,
	"sounds": $ScrollContainer/VBox/Sounds,
	"other": $ScrollContainer/VBox/Other
}

@onready var scroll: ScrollContainer = $ScrollContainer

func _ready():
	var items = self.load_items()
	
	for item in items:
		var entry = CreditsEntry.instantiate()
		entry.set_item(item)
		containers[item.category].add_child(entry)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed :
		if event.is_action_pressed("ui_down", true):
			scroll.set_v_scroll(scroll.get_v_scroll() + SCROLL_STEP)
		elif event.is_action_pressed("ui_up", true):
			scroll.set_v_scroll(scroll.get_v_scroll() - SCROLL_STEP)
		

func load_items() -> Array:
	var file: FileAccess = FileAccess.open(tr(Constants.CREDITS_FILE), FileAccess.READ)
	return JSON.parse_string(file.get_as_text())

func hide_menu():
	self.set_process_unhandled_input(false)
	self.hide()

func show_menu():
	self.scroll.scroll_vertical = 0
	self.set_process_unhandled_input(true)
	self.show()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): 
		self.exit.emit()
		self.get_viewport().set_input_as_handled()
