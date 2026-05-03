extends Area2D


func _on_body_entered(_body: Node2D) -> void:
	_body.call_deferred("queue_free")
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/UI Scenes/win_menu.tscn")
