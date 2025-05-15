extends Enemy

@export var walk_speed = 20.0
@export var starting_orientation = 1

@onready var vertical_raycast: RayCast2D = $VerticalRayCast
@onready var horizontal_raycast: RayCast2D = $HorizontalRayCast
@onready var walk_sound: AudioStreamPlayer2D = $WalkSound

var orientation
var on_screen = false

func _ready():
	self.set_orientation(starting_orientation)
	
func set_orientation(new_orientation):
	self.orientation = sign(new_orientation)
	
	self.horizontal_raycast.position.x = orientation * abs(self.horizontal_raycast.position.x)
	self.horizontal_raycast.target_position.x = orientation * abs(self.horizontal_raycast.target_position.x)
	self.vertical_raycast.position.x = orientation * abs(self.vertical_raycast.position.x)
	self.velocity = Vector2(walk_speed, 0) * orientation
	self.sprite.flip_h = orientation < 0
	
func _physics_process(delta: float) -> void:
	var flipped = false
	if is_on_floor() and not self.vertical_raycast.is_colliding():
		self.set_orientation(-self.orientation)
		flipped = true
		
	if not is_on_floor():
		velocity.y += Constants.GRAVITY * delta
		velocity.y = min(Constants.MAX_FALL_SPEED, velocity.y)
		
	
	if self.get_last_slide_collision() != null and not flipped:
		if horizontal_raycast.is_colliding():
			self.set_orientation(-self.orientation)
			flipped = true
					
	
	self.move_and_slide()


func _on_timer_timeout() -> void:
	if on_screen:
		Entities.create_echo_at(self.position, 2.0)
		walk_sound.play()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	on_screen = false

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	on_screen = true
