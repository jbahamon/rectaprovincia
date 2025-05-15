extends TileMapLayer

var time = 0.12
@export var bgm: AudioStream
@export var max_time: float

func _process(delta):
	time += delta
	
	if time > max_time:
		time = 0
		var x = randi_range(-130,150)
		Entities.create_echo_at(Vector2(x, 0 if x < 80 else -24))
		
		
	
