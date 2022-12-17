extends HBoxContainer

var EVALUATORLABELSCENE = preload("res://Scenes/EvaluatorLabel.tscn")

var AndMode = true
var Negated = false

var ChildEvaluators = []

var HeadEvaluator = false

func _ready():
	if Negated:
		var label = EVALUATORLABELSCENE.instance()
		label.text = "NOT("
		add_child(label)
	elif ChildEvaluators.size() > 1:
		var label = EVALUATORLABELSCENE.instance()
		label.text = "("
		add_child(label)
	
	var firstEvaluator = true
	
	for evaluator in ChildEvaluators:
		if firstEvaluator:
			firstEvaluator = false
		else:
			var label = EVALUATORLABELSCENE.instance()
			if AndMode:
				label.text = "AND"
			else:
				label.text = "OR"
			add_child(label)
		add_child(evaluator)
	
	if Negated or ChildEvaluators.size() > 1:
		var label = EVALUATORLABELSCENE.instance()
		label.text = ")"
		add_child(label)
	
	if HeadEvaluator:
		var tree = get_tree()
		yield(tree, "idle_frame")
		var width = rect_size.x
		var scale = 1.0
		if width > 420.0:
			scale = 420.0 / width
			rect_scale = Vector2(scale, scale)
		yield(tree, "idle_frame")
		modulate = Color(1.0, 1.0, 1.0, 1.0)
		if width > 420.0:
			rect_position.x *= scale
	else:
		modulate = Color(1.0, 1.0, 1.0, 1.0)

func Evaluate(present):
	var valid = AndMode
	
	for evaluator in ChildEvaluators:
		if AndMode:
			valid = valid and evaluator.Evaluate(present)
		else:
			valid = valid or evaluator.Evaluate(present)
	
	if Negated:
		valid = not valid
	
	return valid
