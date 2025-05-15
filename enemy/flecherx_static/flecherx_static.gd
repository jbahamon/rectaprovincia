extends Enemy

var Bullet = preload("res://enemy/flecherx_static/bullet.tscn")
@export var shooting_time = 1.8

var time = 1.5
var shooting = false

@onready var shoot_sound = $ShootSound

func _on_area_2d_body_entered(_body: Node2D) -> void:
	self.shooting = true
	self.time = 1.5

func _on_area_2d_body_exited(_body: Node2D) -> void:
	self.shooting = false
	
func _process(delta: float) -> void:
	
	self.sprite.flip_h = self.global_position.x > Entities.player.global_position.x
	 
	self.time += delta
	if shooting and self.time > self.shooting_time:
		self.time = fmod(self.time, self.shooting_time)
		self.shoot()
	self.collide_with_player()
		
func shoot():
	var facing  = -1 if self.sprite.flip_h else 1
	var bullet = Bullet.instantiate()
	bullet.global_position = self.global_position + Vector2(6 * facing, -8)
	Entities.player.create_echo_at(self.global_position + Vector2(6 * facing, -8))
	Entities.world.add_child(bullet)
	Entities.world.move_child(bullet, 0)
	
	bullet.set_orientation(facing)
	shoot_sound.position.x = 6 * facing
	shoot_sound.play()
	self.sprite.frame = 1
	await get_tree().create_timer(shooting_time/2).timeout
	self.sprite.frame = 0
	

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += Constants.GRAVITY * delta
		velocity.y = min(Constants.MAX_FALL_SPEED, velocity.y)
		
	self.move_and_slide()
