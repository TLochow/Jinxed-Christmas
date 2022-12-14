extends CanvasLayer

var HIGHSCOREENTRYSCENE = preload("res://Scenes/HighscoreEntry.tscn")

onready var CursorLabel = $Control/EnterName/NameCursorLabel
onready var NameLabel1 = $Control/EnterName/NameLabel1
onready var NameLabel2 = $Control/EnterName/NameLabel2
onready var NameLabel3 = $Control/EnterName/NameLabel3
onready var OkLabel = $Control/EnterName/OkLabel
onready var SureLabel = $Control/EnterName/SureLabel

onready var ScoresGrid = $Control/HighScores/Scores

var Score = 0

var Scores = {"Scores": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0], "Names": ["AAA","AAA","AAA","AAA","AAA","AAA","AAA","AAA","AAA","AAA"]}


var EnterNameMode = true
var EnterNameIndex = 0
var NameIndizes = [0, 0, 0]
var Alphabet = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
var ShowCursor = false

var CanContinue = false

func _ready():
	$Control/PresentsLabel.text += str(Score)
	LoadScores()
	if Score <= Scores.Scores[9]:
		ShowHighscores()
	else:
		$Control/EnterName/CursorTimer.start()

func _on_CursorTimer_timeout():
	ShowCursor = not ShowCursor
	CursorLabel.visible = ShowCursor

func _on_ContinueTimer_timeout():
	CanContinue = true
	$Control/HighScores/ContinueLabel.visible = true

func ShowHighscores():
	EnterNameMode = false
	$Control/EnterName.visible = false
	$Control/HighScores.visible = true
	for i in range(5):
		AddHighScoreEntry(i + 1, Scores.Names[i], Scores.Scores[i])
		AddHighScoreEntry(i + 6, Scores.Names[i + 5], Scores.Scores[i + 5])
	$Control/HighScores/ContinueTimer.start()

func AddHighScoreEntry(position, scoreName, score):
	var entry = HIGHSCOREENTRYSCENE.instance()
	entry.Position = position
	entry.Name = scoreName
	entry.Score = score
	ScoresGrid.add_child(entry)

func AddNameToScores():
	var toSave = true
	for i in range(Scores.Scores.size()):
		if toSave and Score > Scores.Scores[i]:
			toSave = false
			Scores.Scores.insert(i, Score)
			Scores.Names.insert(i, GetEnteredName())
			var _oldScore = Scores.Scores.pop_back()
			var _oldName = Scores.Names.pop_back()
	SaveScores()

func GetEnteredName():
	return str(Alphabet[NameIndizes[0]], Alphabet[NameIndizes[1]], Alphabet[NameIndizes[2]])

func ShowName():
	NameLabel1.text = Alphabet[NameIndizes[0]]
	NameLabel2.text = Alphabet[NameIndizes[1]]
	NameLabel3.text = Alphabet[NameIndizes[2]]

func ShowSureText():
	if EnterNameIndex > 2:
		OkLabel.text = "Sure?"
		SureLabel.visible = true
		CursorLabel.set_position(Vector2(-100.0, -100.0))
	else:
		OkLabel.text = "Ok"
		SureLabel.visible = false
		match(EnterNameIndex):
			0:
				CursorLabel.set_position(NameLabel1.get_position() + Vector2(0.0, 8.0))
			1:
				CursorLabel.set_position(NameLabel2.get_position() + Vector2(0.0, 8.0))
			2:
				CursorLabel.set_position(NameLabel3.get_position() + Vector2(0.0, 8.0))

func LoadScores():
	var file = File.new()
	if file.file_exists("user://highscores.jc"):
		file.open("user://highscores.jc", File.READ)
		Scores = parse_json(file.get_as_text())
		file.close()

func SaveScores():
	var file = File.new()
	file.open("user://highscores.jc", File.WRITE)
	file.store_line(to_json(Scores))
	file.close()

func _input(event):
	if EnterNameMode:
		if event.is_action_pressed("ui_up"):
			if EnterNameIndex < 3:
				NameIndizes[EnterNameIndex] = wrapi(NameIndizes[EnterNameIndex] + 1, 0, Alphabet.size())
				ShowName()
		elif event.is_action_pressed("ui_down"):
			if EnterNameIndex < 3:
				NameIndizes[EnterNameIndex] = wrapi(NameIndizes[EnterNameIndex] - 1, 0, Alphabet.size())
				ShowName()
		elif event.is_action_pressed("ui_left"):
			EnterNameIndex = max(EnterNameIndex - 1, 0)
			ShowSureText()
		elif event.is_action_pressed("ui_right"):
			EnterNameIndex = min(EnterNameIndex + 1, 4)
			ShowSureText()
			if EnterNameIndex == 4:
				AddNameToScores()
				ShowHighscores()
	elif CanContinue:
		if event is InputEventKey and event.pressed:
			CanContinue = false
			SceneChanger.ChangeScene("res://Scenes/Main.tscn")
