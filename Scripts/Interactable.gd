class_name Interactable
extends Area2D

signal On_Interacted
var player:PlayerCharacter

func interact() -> void:
	print("Interacted")
	On_Interacted.emit()

func _on_body_entered(body) -> void:
	player = body as PlayerCharacter
	if player:
		player.start_interaction_process(self)

func _on_body_exited(body) -> void:
	if player == body:
		player.stop_interaction_process()
