extends CharacterBody2D

class_name Projectile

@onready var sprite = $Sprite2D
@export var lifetime = 2.0
@export var damage = 5.0
@export var hit_group = "player"

var time = 0

func set_orientation(orientation):
	var facing_left = orientation < 0
	
	sprite.flip_h = facing_left
	velocity = Vector2(150, 0) * (-1 if facing_left else 1)
	
func _physics_process(delta: float) -> void:
	self.move_and_slide()
	
	if self.get_last_slide_collision() != null:
		
		for collision_index in range(self.get_slide_collision_count()):
			var collision = self.get_slide_collision(collision_index)
			var collider = collision.get_collider()
			if collider is CharacterBody2D and collider.is_in_group(hit_group):
				collider.take_damage(self.damage)
		
	time += delta
	
	if time > lifetime or self.get_last_slide_collision() != null:
		self.queue_free()
			
	
