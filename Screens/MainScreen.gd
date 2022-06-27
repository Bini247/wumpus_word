extends Control

export(String, FILE) var next_scene_path: = ""
	
func _on_TextureButton_pressed():
	GameData.is_ia_mode = false
	get_tree().change_scene(next_scene_path)

func _on_TextureButton3_pressed():
	GameData.is_ia_mode = true
	get_tree().change_scene(next_scene_path)


func _on_TextureButton2_pressed():
	get_tree().quit()


func _on_TextureButton_mouse_entered():
	$VBoxContainer/VBoxContainer/TextureButton/RichTextLabel.self_modulate = Color(128,128,128,1)


func _on_TextureButton_mouse_exited():
	$VBoxContainer/VBoxContainer/TextureButton/RichTextLabel.self_modulate = Color(1,1,1,1)


func _on_TextureButton3_mouse_entered():
	$VBoxContainer/VBoxContainer/TextureButton3/RichTextLabel.self_modulate = Color(128,128,128,1)


func _on_TextureButton3_mouse_exited():
	$VBoxContainer/VBoxContainer/TextureButton3/RichTextLabel.self_modulate = Color(1,1,1,1)


func _on_TextureButton2_mouse_entered():
	$VBoxContainer/VBoxContainer/TextureButton2/RichTextLabel.self_modulate = Color(128,128,128,1)


func _on_TextureButton2_mouse_exited():
	$VBoxContainer/VBoxContainer/TextureButton2/RichTextLabel.self_modulate = Color(1,1,1,1)
