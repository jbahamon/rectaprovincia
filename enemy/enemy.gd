extends CharacterBody2D

class_name Enemy

var GetHitMaterial = preload("res://common/damaged.tres")
var HealthPickup = preload("res://object/health_pickup.tscn")
@export var max_hp = 1

# @onready var anim_player = $AnimationPlayer
@onready var hp = max_hp
@onready var sprite: Sprite2D = $Sprite2D
@onready var get_hit_sound: AudioStreamPlayer2D = $GetHitSound

@export var contact_damage = 3
@export var knockback_speed = 20.0
@export var invuln_damage_time = 0.3

@export var health_spawn_position: Vector2 = Vector2(0, -12)
var dead = false
var invulnerable = false
var in_contact = false

func take_damage(damage):
	if self.invulnerable:
		return
		
	self.hp -= damage
	get_hit_sound.play()
	
	if self.hp <= 0 and not self.dead:
		self.dead = true
		self.sprite.material = GetHitMaterial
		self.process_mode = Node.PROCESS_MODE_DISABLED
		self.set_physics_process(false)
		await get_tree().create_timer(0.6).timeout
		self.spawn_health()
		self.remove()
	else:
		self.invulnerable = true
		await get_tree().create_timer(self.invuln_damage_time).timeout
		self.invulnerable = false

func _process(_delta: float):
	self.collide_with_player()
	
 
func _on_contact_damage_body_entered(body: Node2D) -> void:
	if body == Entities.player and self.contact_damage > 0:
		self.in_contact = true

func _on_contact_damage_body_exited(body: Node2D) -> void:
	if body == Entities.player:
		self.in_contact = false
		
func remove():
	self.queue_free()

func collide_with_player():
	if in_contact and not Entities.player.invulnerable:
		Entities.player.take_damage(self.contact_damage)
		Entities.player.velocity = self.global_position.direction_to(Entities.player.global_position) * self.knockback_speed

func spawn_health():
	if Entities.player.hp < Entities.player.max_hp and randf() < 0.7:
		var pickup = HealthPickup.instantiate()
		Entities.world.add_child(pickup)
		Entities.world.move_child(pickup, 0)
		pickup.global_position = self.global_position + self.health_spawn_position + Vector2(randi_range(-3, 3), randi_range(-3, 3))
