extends Control

var Mode = 0
var Value = 0

func _ready():
	var sprite
	match(Mode):
		0:
			sprite = $Body
		1:
			sprite = $Top
		2:
			sprite = $Ribbon
	sprite.visible = true
	sprite.frame = Value

func Evaluate(present):
	var valid = false
	
	match(Mode):
		0:
			valid = Value == present.Body
		1:
			valid = Value == present.Top
		2:
			valid = Value == present.Ribbon
	
	return valid
