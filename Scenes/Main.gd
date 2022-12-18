extends Node2D

var PRESENTPLATFORMSCENE = preload("res://Scenes/PresentPlatform.tscn")

var ENDSCREENSCENE = preload("res://Scenes/EndScreen.tscn")

onready var PickupLight = $PickupArea/Light2D

onready var GenerateOrderTimer = $GenerateOrderTimer
onready var EvaluatorNode = $EvaluatorNode

onready var LivesLabel = $UI/Lives/Label
onready var ScoreLabel = $UI/Score/Label
onready var TimeBar = $UI/TimeBar

var CountTime = false
var TimeLeft = 0.0

var Noise
var NoiseVector
var LightColorHue = 0.0

var OrderScore = 0
var OrderEvaluator
var ReceptiveForPresents = false

var Score = 0
var Lives = 9

func _ready():
	randomize()
	
	Noise = OpenSimplexNoise.new()
	Noise.seed = randi()
	Noise.period = 20.0
	Noise.persistence = 0.8
	NoiseVector = Vector2(0.0, 0.0)
	
	LightColorHue = randf()
	
	var platformsNode = $PresentPlatforms
	for i in range(22):
		var platform = PRESENTPLATFORMSCENE.instance()
		platform.MoveOffset = i * 32.0
		platformsNode.add_child(platform)
	
	OrderScore = 0
	GenerateOrderTimer.start()
	Score = 0
	Lives = 9

func _process(delta):
	NoiseVector += Vector2(delta * 2.0, delta * 2.0)
	PickupLight.set_position(Vector2(0.0, -96.0) + (Vector2(Noise.get_noise_2d(NoiseVector.x, NoiseVector.y), Noise.get_noise_2d(NoiseVector.y, NoiseVector.x)) * 15.0))
	LightColorHue = wrapf(LightColorHue + (delta * 0.05), 0.0, 1.0)
	PickupLight.color = Color.from_hsv(LightColorHue, 1.0, 1.0)
	
	if CountTime:
		TimeLeft = max(TimeLeft - (delta * 5.0), 0.0)
		TimeBar.value = TimeLeft
		if TimeLeft == 0.0:
			CountValid(false)

func _on_GenerateOrderTimer_timeout():
	TimeLeft = 100.0
	TimeBar.value = TimeLeft
	TimeBar.visible = true
	CountTime = true
	ReceptiveForPresents = true
	var presents = get_tree().get_nodes_in_group("Present")
	var present = presents[randi() % presents.size()]
	OrderScore += 1
	var difficulty = int(OrderScore / 5)
	OrderEvaluator = Global.GetEvaluatorForPresent(present, difficulty)
	EvaluatorNode.add_child(OrderEvaluator)

func PresentCollected(present):
	if ReceptiveForPresents:
		var valid = OrderEvaluator.Evaluate(present)
		CountValid(valid)
	present.queue_free()

func CountValid(valid):
	ReceptiveForPresents = false
	if valid:
		Score += 1
	else:
		Lives -= 1
		OrderScore = max(OrderScore - 10, 0)
		if Lives == 0:
			$Player.HasControl = false
			var endScreen = ENDSCREENSCENE.instance()
			endScreen.Score = Score
			add_child(endScreen)
	OrderEvaluator.queue_free()
	
	LivesLabel.text = str(Lives)
	ScoreLabel.text = str(Score)
	TimeBar.visible = false
	CountTime = false
	
	SoundPlayer.PlayValidationSound(valid)
	
	if Lives > 0:
		GenerateOrderTimer.start()
