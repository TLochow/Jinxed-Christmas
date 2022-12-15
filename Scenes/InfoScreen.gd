extends Control

var PRESENTSCENE = preload("res://Scenes/Present.tscn")

onready var PresentBodySprite = $ColorRect/PresentBodySprite
onready var PresentTopSprite = $ColorRect/PresentTopSprite
onready var PresentRibbonSprite = $ColorRect/PresentRibbonSprite
onready var EvaluatorNode = $ColorRect/EvaluatorNode

onready var ThrownPresent = $ColorRect/ThrownPresent

var PresentThrown = true
var CurrentPresent

func _ready():
	randomize()
	$AnimationPlayer.play("Info")
	$ColorRect/GeneratePresentTimer.start()
	ShowNewPresent()
	$ColorRect/ThrowPresentTimer.start()
	ThrowPresent()

func _on_GeneratePresentTimer_timeout():
	ShowNewPresent()

func ShowNewPresent():
	var present = {"Body": randi() % 8, "Top": randi() % 8, "Ribbon": randi() % 8}
	PresentBodySprite.frame = present.Body
	PresentTopSprite.frame = present.Top
	PresentRibbonSprite.frame = present.Ribbon
	for child in EvaluatorNode.get_children():
		child.queue_free()
	EvaluatorNode.add_child(Global.GetEvaluatorForPresent(present, randi() % 4))

func _on_ThrowPresentTimer_timeout():
	ThrowPresent()

func ThrowPresent():
	PresentThrown = not PresentThrown
	if PresentThrown:
		CurrentPresent.Fall(Vector2(-300.0, -10.0))
	else:
		CurrentPresent = PRESENTSCENE.instance()
		ThrownPresent.add_child(CurrentPresent)

func _input(event):
	if event is InputEventKey and event.pressed:
		SceneChanger.ChangeScene("res://Scenes/Main.tscn")
