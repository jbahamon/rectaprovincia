extends Enemy


@export var base_velocity = Vector2(-120, -40)

@onready var despawn_timer: Timer = $Timer
@onready var spawner_visibility_notifier: VisibleOnScreenNotifier2D = $SpawnerVisible
@onready var scream: AudioStreamPlayer2D = $ScreamSound
@onready var scream_timer: Timer = $SoundTimer

var facing: int = -1
var time = 0.0
var period = 1.5
var original_position: Vector2
var is_spawner_visible = false

func _ready() -> void:
	self.original_position = self.global_position
	self.set_physics_process(false)
	
func _physics_process(delta: float) -> void:
	time = fmod(time + delta, period) 
	self.velocity = Vector2(base_velocity.x * facing, base_velocity.y * cos(2 * PI * time / period)) 
	move_and_slide()
	self.spawner_visibility_notifier.global_position = original_position

func remove():
	self.despawn_timer.stop()
	self.scream_timer.stop()
	self.material = null
	self.sprite.visible = false
	$CollisionShape2D.disabled = true
	$ContactDamage.monitoring = false
	self.set_physics_process(false)
	self.hp = max_hp
	self.global_position = self.original_position
	self.spawner_visibility_notifier.global_position = original_position

func on_sprite_invisible():
	self.despawn_timer.start()
	
func on_sprite_visible():
	self.despawn_timer.stop()
	
func on_spawner_invisible():
	self.is_spawner_visible = false
	
func on_spawner_visible() -> void:
	if not self.sprite.visible and not self.is_spawner_visible:
		self.sprite.visible = true
		$CollisionShape2D.disabled = false
		$ContactDamage.monitoring = true
		self.set_physics_process(true)
		self.sprite.flip_h = self.global_position.x > Entities.player.global_position.x
		self.facing  = -1 if self.sprite.flip_h else 1
		_on_sound_timer_timeout()
	self.is_spawner_visible = true
	self.despawn_timer.stop()


func _on_sound_timer_timeout() -> void:
	scream.play()
	scream_timer.start()
	Entities.create_echo_at(self.position)
