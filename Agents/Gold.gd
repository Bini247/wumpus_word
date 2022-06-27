extends StaticBody2D

var bullet_tex1 = preload("res://Assets/gold_chest_open.png")

var type = 'gold'

func set_open():
	$Sprite.set_texture(bullet_tex1)
