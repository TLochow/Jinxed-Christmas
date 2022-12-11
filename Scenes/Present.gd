extends KinematicBody2D

var Body = 0
var Top = 0
var Ribbon = 0

var Following = false
var ToFollow
var Falling = false

var Motion = Vector2(0.0, 0.0)
var DownMotionLimitDefault = 1200.0
var yMotionModificator = 960.0

func _ready():
	Body = randi() % 8
	Top = randi() % 8
	Ribbon = randi() % 8
	
	$Body.frame = Body
	$Top.frame = Top
	$Ribbon.frame = Ribbon

func _process(delta):
	if Following:
		var pos = get_global_position()
		var dirToFollow = ToFollow.get_position() - pos
		var moveSpeed = max(dirToFollow.length(), 24.0) - 24.0
		var _pos = move_and_slide(dirToFollow.normalized() * moveSpeed)
	elif Falling:
		Motion.y = min(Motion.y + (yMotionModificator * delta), DownMotionLimitDefault)
		Motion = move_and_slide_with_snap(Motion, Vector2(0.0, -32.0), Vector2(0.0, -1.0), false, 4, 0.785398, false)
		if get_position().y > 400.0:
			queue_free()

func PickUp(toFollow):
	ToFollow = toFollow
	remove_from_group("Present")
	get_parent().PresentPickedUp()

func Fall(direction):
	Falling = true
	Motion = direction
