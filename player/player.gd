extends CharacterBody2D

enum Weapons {
	CHALLANCO,
	LEVISTERIO
}
var VisionCircle = preload("res://player/vision_circle.tscn")
var Echo = preload("res://player/echo.tscn")
var PlayerBullet = preload("res://player/player_bullet.tscn")
var Dust = preload("res://player/dust.tscn")
var GetHitMaterial = preload("res://common/damaged.tres")

@export var jump_power = 200.0
@export var horizontal_speed = 120.0

@export var helpless_hit_time = 0.4
@export var invuln_hit_time = 0.8

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var darkness: CanvasGroup = $Darkness
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var shoot_timer: Timer = $ShootAnimTimer

@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound
@onready var get_hit_sound: AudioStreamPlayer2D = $GetHitSound
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var land_sound: AudioStreamPlayer2D = $LandSound
@onready var challanco_sound: AudioStreamPlayer2D = $ChallancoSound
@onready var heal_sound: AudioStreamPlayer2D = $HealSound


@export var max_hp = 100
@onready var hp = max_hp

var invulnerable = false

var unlocked_weapons = []
var current_weapon = -1
var challanco_unlocked = false

var current_vision = 0
var max_vision = 2

var weapons = {
	Weapons.LEVISTERIO: {
		"unlocked": false,
		"name": "Levisterio",
	}
}

var facing: int:
	get:
		return 1 if not sprite.flip_h else -1

var current_weapon_name:
	get:
		if len(self.unlocked_weapons) > 0:
			return self.weapons[self.unlocked_weapons[self.current_weapon]].name
		else:
			return null

var was_on_floor = true

func unlock_weapon(weapon):
	self.weapons[weapon]["unlocked"] = true
	self.unlocked_weapons = self.weapons.keys().filter(func (x): return weapons[x]["unlocked"])
	self.current_weapon = self.unlocked_weapons.find(weapon)
	Entities.ui.update()

func toggle_weapon():
	if len(self.unlocked_weapons) == 0:
		return
	self.current_weapon = (self.current_weapon + 1) % len(self.unlocked_weapons)
	Entities.ui.update()
	
func _physics_process(delta: float) -> void:
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	var has_control = self.is_processing_unhandled_input()
	if has_control:
		velocity.x = horizontal_speed * horizontal_direction
	else:
		horizontal_direction = sign(velocity.x)
	
	if horizontal_direction != 0:
		self.sprite.flip_h = horizontal_direction < 0
	
	if not was_on_floor:
		velocity.y += Constants.GRAVITY * delta
		velocity.y = min(Constants.MAX_FALL_SPEED, velocity.y)
	 
	move_and_slide()
	
	if not was_on_floor and is_on_floor():
		land_sound.play()
		self.create_dust()
	
	was_on_floor = is_on_floor()
	
	if not has_control:
		return
		
	var anim = self.get_anim()
	
	if is_on_floor():
		if  horizontal_direction == 0 and anim != "idle" and anim != "shoot":
			play_anim("idle")
		elif horizontal_direction != 0:
			if anim != "walk" and anim != "walk_shoot":
				play_anim("walk")
	elif anim != "jump" or (anim == "jump" and self.shoot_timer.is_stopped() or self.shoot_timer.time_left == 0):
		play_anim("jump")
	
func _unhandled_input(event: InputEvent) -> void:
	var handled = false
	if event.is_action_pressed("jump") and is_on_floor():
		jump_sound.play()
		self.create_dust()
		velocity.y = -jump_power
		handled = true
			
	if event.is_action_pressed("toggle_weapon"):
		self.toggle_weapon()
		get_viewport().set_input_as_handled()
		handled = true
	elif event.is_action_pressed("shoot") and self.current_weapon >= 0 and self.allowed_to_shoot(self.unlocked_weapons[self.current_weapon]):
		self.shoot()
		if self.is_on_floor():
			self.play_anim("shoot" if self.get_anim() != "walk" else "walk_shoot")
		else:
			self.play_anim("jump_shoot")
		self.shoot_timer.start()
		handled = true
	elif event.is_action_pressed("challanco") and self.allowed_to_shoot(Weapons.CHALLANCO):
		self.create_circle_at(self.global_position + Vector2(0, -10), 1.0, 1.0, Vector2(40, 0))
		if self.is_on_floor():
			self.play_anim("shoot" if self.get_anim() != "walk" else "walk_shoot")
		else:
			self.play_anim("jump_shoot")
		self.shoot_timer.start()
		handled = true
	if handled:
		get_viewport().set_input_as_handled()

func _on_shoot_anim_timer_timeout() -> void:
	var anim = self.get_anim()
	match anim:
		"walk_shoot":
			self.play_anim("walk")
		"jump_shoot":
			self.play_anim("jump")

func create_circle_at(circle_position: Vector2, size, duration, circle_velocity, external=false):
	self.challanco_sound.play()
	var circle: Node = VisionCircle.instantiate()
	if external:
		circle.process_mode = Node.PROCESS_MODE_ALWAYS
	circle.size = size
	circle.duration = duration
	circle.velocity = circle_velocity * self.facing
	darkness.add_child(circle)
	circle.anchor(circle_position)
	if not external:
		self.current_vision += 1
		Entities.ui.update()
		await circle.finished
		self.current_vision -= 1
		Entities.ui.update()
	
	
func allowed_to_shoot(weapon):
	match weapon:
		Weapons.CHALLANCO:
			return self.challanco_unlocked and self.current_vision < self.max_vision
		Weapons.LEVISTERIO:
			return true
			
func shoot():
	shoot_sound.play()
	match self.unlocked_weapons[self.current_weapon]:
		Weapons.LEVISTERIO:
			var bullet = PlayerBullet.instantiate()
			bullet.global_position = self.global_position + Vector2(0, -12.5)
			Entities.world.add_child(bullet)
			bullet.set_orientation(facing)

func take_damage(damage):
	get_hit_sound.play()
	self.hp = clamp(self.hp - damage, 0, self.max_hp)
	Entities.ui.update()
	
	if self.hp == 0:
		self.get_hit_sound.process_mode = Node.PROCESS_MODE_ALWAYS
		Entities.world.end_game(false)
		return
	
	self.play_anim("hit")
	self.sprite.material = GetHitMaterial
	self.set_process_unhandled_input(false)
	self.invulnerable = true
	await self.get_tree().create_timer(self.helpless_hit_time).timeout
	self.set_process_unhandled_input(true)
	
	await self.get_tree().create_timer(self.invuln_hit_time - self.helpless_hit_time).timeout
	self.invulnerable = false
	self.play_anim("idle" if self.is_on_floor() else "jump")
	self.sprite.material = null
	
func create_echo_at(echo_position: Vector2, time_scale = 1.0):
	var echo: AnimatedSprite2D = Echo.instantiate()
	echo.speed_scale = time_scale
	darkness.add_child(echo)
	darkness.move_child(echo, 1)
	echo.anchor(echo_position)
	

func clear_vision():
	for child in darkness.get_children():
		if child.name != "Dark":
			child.queue_free()
	self.current_vision = 0
	Entities.ui.update()

func get_anim():
	return self.animation_state.get_current_node()
	
func play_anim(anim_name: String):
	animation_state.travel(anim_name)

func create_dust():
	var dust: AnimatedSprite2D = Dust.instantiate()
	Entities.world.add_child(dust)
	dust.position = self.position + Vector2(-10 * facing, -4)
	dust.flip_h = self.sprite.flip_h
