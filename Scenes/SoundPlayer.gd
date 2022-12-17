extends Node2D

onready var Correct = $Correct
onready var Wrong = $Wrong

func _ready():
	var music = $Music
	music.play()
	var tween = $Tween
	tween.interpolate_property(music, "volume_db", -80.0, -10.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func PlayValidationSound(valid):
	if valid:
		Correct.play()
	else:
		Wrong.play()
