extends KinematicBody2D

signal Collected(present)

var Body = 0
var Top = 0
var Ribbon = 0

var Falling = false
var FallingInReverse = false

var Motion = Vector2(0.0, 0.0)
var DownMotionLimitDefault = 1200.0
var yMotionModificator = 960.0

var SentCollected = false

func _ready():
	Body = randi() % 8
	Top = randi() % 8
	Ribbon = randi() % 8
	
	$Body.frame = Body
	$Top.frame = Top
	$Ribbon.frame = Ribbon
	
	set_process(false)

func _process(delta):
	if Falling:
		if FallingInReverse:
			Motion.y = max(Motion.y - (yMotionModificator * delta), -DownMotionLimitDefault)
		else:
			Motion.y = min(Motion.y + (yMotionModificator * delta), DownMotionLimitDefault)
		Motion = move_and_slide_with_snap(Motion, Vector2(0.0, -32.0), Vector2(0.0, -1.0), false, 4, 0.785398, false)
		var pos = get_position()
		if pos.y > 400.0:
			queue_free()
		elif pos.y < -100.0 and not SentCollected:
			SentCollected = true
			emit_signal("Collected", self)

func PickUp():
	remove_from_group("Present")
	get_parent().PresentPickedUp()

func Fall(direction, reverse = false):
	Falling = true
	Motion = direction
	FallingInReverse = reverse
	SentCollected = not reverse
	set_process(true)
