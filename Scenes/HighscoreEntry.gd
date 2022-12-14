extends CenterContainer

var Position = 1
var Name = "AAA"
var Score = 0

func _ready():
	$HBoxContainer/NumberLabel.text = str(Position, ".")
	$HBoxContainer/NameLabel.text = Name
	$HBoxContainer/ScoreLabel.text = str(Score)
