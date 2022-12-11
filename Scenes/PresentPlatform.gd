extends Node2D

var PRESENTSCENE = preload("res://Scenes/Present.tscn")

var HasPresent = false
var MoveOffset = 0.0

func _process(_delta):
	var pos = Vector2(496.0, wrapf((OS.get_ticks_msec() * 0.025) + MoveOffset, -32.0, 672.0))
	if pos.y > 320.0:
		pos.x = 16.0
		pos.y = 640.0 - pos.y
	if not HasPresent:
		if pos.y > 304.0 or pos.y < -16.0:
			HasPresent = true
			add_child(PRESENTSCENE.instance())
	set_global_position(pos)

func PresentPickedUp():
	HasPresent = false
