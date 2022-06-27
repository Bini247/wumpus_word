extends Node2D

func _ready():
	$Grid/Player.position = $Grid.map_to_world(Vector2(1,6))

