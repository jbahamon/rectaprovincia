extends Area2D

@export var target_level_name: String
@export var target_position: Vector2

func _on_body_entered(_body: Node2D) -> void:
	Entities.world.switch_level(target_level_name, target_position)
