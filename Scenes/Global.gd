extends Node

var BASICEVALUATORSCENE = preload("res://Scenes/BasicEvaluator.tscn")
var EVALUATORSCENE = preload("res://Scenes/Evaluator.tscn")

func ReparentNode(child, newParent):
	var oldParent = child.get_parent()
	oldParent.call_deferred("remove_child", child)
	newParent.call_deferred("add_child", child)

func GetEvaluatorForPresent(present, difficulty):
	var mainEvaluator = EVALUATORSCENE.instance()
	mainEvaluator.AndMode = false
	var bodyEvaluator = BASICEVALUATORSCENE.instance()
	bodyEvaluator.Mode = 0
	bodyEvaluator.Value = present.Body
	mainEvaluator.ChildEvaluators.append(bodyEvaluator)
	var topEvaluator = BASICEVALUATORSCENE.instance()
	topEvaluator.Mode = 1
	topEvaluator.Value = present.Top
	mainEvaluator.ChildEvaluators.append(topEvaluator)
	var ribbonEvaluator = BASICEVALUATORSCENE.instance()
	ribbonEvaluator.Mode = 2
	ribbonEvaluator.Value = present.Ribbon
	mainEvaluator.ChildEvaluators.append(ribbonEvaluator)
	for _i in range(difficulty):
		var evaluatorToChange = mainEvaluator
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
	return mainEvaluator
