extends Control



func _on_button_new_game_pressed() -> void:
	SceneLoader.switch_scene("res://scenes/intro.tscn")


func _on_button_exit_pressed() -> void:
	get_tree().quit()
