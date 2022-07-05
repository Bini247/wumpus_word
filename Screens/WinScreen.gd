extends Control

export(String, FILE) var level: = ""


func _on_TextureButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Screens/MainScreen.tscn")


func _on_TextureButton2_pressed():
	get_tree().quit()


func _on_PlayAgain_pressed():
	get_tree().paused = false
	get_tree().change_scene(level)
