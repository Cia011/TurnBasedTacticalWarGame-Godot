extends Node2D
@onready var sprite_2d: Sprite2D = $Sprite2D

func set_up(event:BaseEvent):
	event.event_icon_node = self
	sprite_2d.texture = event.icon
	#print(event.icon)
	position = WorldGridManager.get_world_position(event.grid_position)
