extends Node2D

signal start_init


func _ready():
	start_init.emit()
