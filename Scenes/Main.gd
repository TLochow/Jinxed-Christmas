extends Node2D

var PRESENTPLATFORMSCENE = preload("res://Scenes/PresentPlatform.tscn")
var BASICEVALUATORSCENE = preload("res://Scenes/BasicEvaluator.tscn")
var EVALUATORSCENE = preload("res://Scenes/Evaluator.tscn")

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
	NoiseVector += Vector2(delta, delta)
	PickupLight.set_position(Vector2(0.0, -96.0) + (Vector2(Noise.get_noise_2d(NoiseVector.x, NoiseVector.y), Noise.get_noise_2d(NoiseVector.y, NoiseVector.x)) * 10.0))
	LightColorHue = wrapf(LightColorHue + (delta * 0.05), 0.0, 1.0)
	PickupLight.color = Color.from_hsv(LightColorHue, 1.0, 1.0)
	
	if CountTime:
		TimeLeft = max(TimeLeft - (delta * 2.0), 0.0)
		TimeBar.value = TimeLeft
		if TimeLeft == 0.0:
			CountValid(false)

func _on_GenerateOrderTimer_timeout():
	TimeLeft = 100.0
	TimeBar.value = TimeLeft
	TimeBar.visible = true
	CountTime = true
	var presents = get_tree().get_nodes_in_group("Present")
	var present = presents[randi() % presents.size()]
	OrderScore += 1
	OrderEvaluator = EVALUATORSCENE.instance()
	OrderEvaluator.AndMode = false
	var bodyEvaluator = BASICEVALUATORSCENE.instance()
	bodyEvaluator.Mode = 0
	bodyEvaluator.Value = present.Body
	OrderEvaluator.ChildEvaluators.append(bodyEvaluator)
	var topEvaluator = BASICEVALUATORSCENE.instance()
	topEvaluator.Mode = 1
	topEvaluator.Value = present.Top
	OrderEvaluator.ChildEvaluators.append(topEvaluator)
	var ribbonEvaluator = BASICEVALUATORSCENE.instance()
	ribbonEvaluator.Mode = 2
	ribbonEvaluator.Value = present.Ribbon
	OrderEvaluator.ChildEvaluators.append(ribbonEvaluator)
	var difficulty = int(OrderScore / 5)
	for _i in range(difficulty):
		var evaluatorToChange = OrderEvaluator
		var parentEvaluator
		var negated = false
		while "ChildEvaluators" in evaluatorToChange:
			if evaluatorToChange.Negated:
				negated = not negated
			parentEvaluator = evaluatorToChange
			evaluatorToChange = evaluatorToChange.ChildEvaluators[randi() % evaluatorToChange.ChildEvaluators.size()]
		if randi() % 2 == 0 or parentEvaluator.ChildEvaluators.size() == 1:
			var evaluator = EVALUATORSCENE.instance()
			var negate = randi() % 2 == 0
			if negate:
				negated = not negated
			evaluator.Negated = negate
			var andMode = randi() % 2 == 0
			evaluator.AndMode = andMode
			if andMode:
				var firstCompareMode = randi() % 3
				var secondCompareMode = randi() % 3
				while secondCompareMode == firstCompareMode:
					secondCompareMode = randi() % 3
				var firstEvaluator = BASICEVALUATORSCENE.instance()
				var secondEvaluator = BASICEVALUATORSCENE.instance()
				firstEvaluator.Mode = firstCompareMode
				secondEvaluator.Mode = secondCompareMode
				match(firstCompareMode):
					0:
						firstEvaluator.Value = present.Body
					1:
						firstEvaluator.Value = present.Top
					2:
						firstEvaluator.Value = present.Ribbon
				match(secondCompareMode):
					0:
						secondEvaluator.Value = present.Body
					1:
						secondEvaluator.Value = present.Top
					2:
						secondEvaluator.Value = present.Ribbon
				if negated:
					var before = firstEvaluator.Value
					while firstEvaluator.Value == before:
						firstEvaluator.Value = randi() % 8
					before = secondEvaluator.Value
					while secondEvaluator.Value == before:
						secondEvaluator.Value = randi() % 8
				if randi() % 2 == 0:
					evaluator.ChildEvaluators.append(firstEvaluator)
					evaluator.ChildEvaluators.append(secondEvaluator)
				else:
					evaluator.ChildEvaluators.append(secondEvaluator)
					evaluator.ChildEvaluators.append(firstEvaluator)
			else:
				var compareMode = randi() % 3
				var correctEvaluator = BASICEVALUATORSCENE.instance()
				var randomEvaluator = BASICEVALUATORSCENE.instance()
				correctEvaluator.Mode = compareMode
				randomEvaluator.Mode = compareMode
				match(compareMode):
					0:
						correctEvaluator.Value = present.Body
					1:
						correctEvaluator.Value = present.Top
					2:
						correctEvaluator.Value = present.Ribbon
				randomEvaluator.Value = randi() % 8
				while randomEvaluator.Value == correctEvaluator.Value:
					randomEvaluator.Value = randi() % 8
				if randi() % 2 == 0:
					evaluator.ChildEvaluators.append(correctEvaluator)
					evaluator.ChildEvaluators.append(randomEvaluator)
				else:
					evaluator.ChildEvaluators.append(randomEvaluator)
					evaluator.ChildEvaluators.append(correctEvaluator)
			var indexToAdd = parentEvaluator.ChildEvaluators.find(evaluatorToChange)
			parentEvaluator.ChildEvaluators.insert(indexToAdd, evaluator)
		parentEvaluator.ChildEvaluators.erase(evaluatorToChange)
		evaluatorToChange.queue_free()
	EvaluatorNode.add_child(OrderEvaluator)

func PresentCollected(present):
	var valid = OrderEvaluator.Evaluate(present)
	present.queue_free()
	CountValid(valid)

func CountValid(valid):
	if valid:
		Score += 1
	else:
		Lives -= 1
		if Lives == 0:
			$Player.HasControl = false
	OrderEvaluator.queue_free()
	
	LivesLabel.text = str(Lives)
	ScoreLabel.text = str(Score)
	TimeBar.visible = false
	CountTime = false
	
	if Lives > 0:
		GenerateOrderTimer.start()
