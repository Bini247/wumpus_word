extends Control

var is_light_on = false

var is_paused = false

func _ready():
	if !GameData.is_ia_mode: $VBoxContainer2/TextureButton.visible = false

func _on_TextureButton_pressed():
	owner.owner.get_node('Grid/CanvasModulate').visible = is_light_on
	owner.get_node('Light2D').enabled = is_light_on
	is_light_on = !is_light_on

func set_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	$PauseOverlay.visible = is_paused

func _unhandled_input(event):
	if event.is_action_pressed('pause'): set_pause()
