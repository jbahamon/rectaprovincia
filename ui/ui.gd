extends VBoxContainer

@onready var status = $Status
@onready var dialog = $Dialog 
@onready var health = $Status/HBoxContainer/Health/HealthAmount
@onready var vision_container = $Status/HBoxContainer/Vision
@onready var eyes = [$Status/HBoxContainer/Vision/Eye1, $Status/HBoxContainer/Vision/Eye2]
func update():
	self.health.text = "%d/%d" % [Entities.player.hp, Entities.player.max_hp]
	
	if Entities.player.challanco_unlocked:
		self.vision_container.show()
		for i in range(Entities.player.max_vision):
			eyes[i].modulate = Constants.TRANSPARENT if i >= (Entities.player.max_vision -  Entities.player.current_vision) else Color.WHITE

	else:
		self.vision_container.hide()
	
func open_dialog(text):
	self.status.hide()
	self.dialog.open(text)
	await self.dialog.closed
	self.status.show()
