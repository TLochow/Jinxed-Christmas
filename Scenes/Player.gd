extends KinematicBody2D

onready var SpriteNode = $Sprite
onready var AnimationPlayerNode = $AnimationPlayer
onready var PresentNode = $Sprite/PresentNode

var Motion = Vector2(0.0, 0.0)
var CoyoteTime = 0.0
var JumpBoost = 0.0

var DownMotionLimitDefault = 1200.0
var yMotionModificator = 960.0
var xMoveDefault = 80.0
var JumpBoostDefault = 1000.0
var JumpBoostYMotionModificator = -200.0
var JumpBoostDefaultModificator = 2400.0

var CarriesPresent = false
var Present

func _physics_process(delta):
	var isOnFloor = is_on_floor()
	Motion.y = min(Motion.y + (yMotionModificator * delta), DownMotionLimitDefault)
	
	if Motion.x < 0.0:
		SpriteNode.scale = Vector2(1.0, 1.0)
	elif Motion.x > 0.0:
		SpriteNode.scale = Vector2(-1.0, 1.0)
		
	var xMove = 0.0
	if Input.is_action_pressed("ui_left"):
		xMove -= xMoveDefault
	if Input.is_action_pressed("ui_right"):
		xMove += xMoveDefault
	if Input.is_action_pressed("ui_up"):
		if CoyoteTime > 0.0:
			CoyoteTime = 0.0
			JumpBoost = JumpBoostDefault
			Motion.y = JumpBoostYMotionModificator
		elif JumpBoost > 0.0:
			Motion.y -= JumpBoost * delta
			JumpBoost = max(JumpBoost - (delta * JumpBoostDefaultModificator), 0.0)
	
	if not CarriesPresent:
		xMove *= 2.0
	Motion.x = xMove
	Motion = move_and_slide_with_snap(Motion, Vector2(0.0, -32.0), Vector2(0.0, -1.0), false, 4, 0.785398, false)
	
	if isOnFloor:
		var moving = false
		if Motion.x < -1.0:
			moving = true
		elif Motion.x > 1.0:
			moving = true
		if moving:
			SwitchAnimation(AnimationPlayerNode, "Walk")
		else:
			SwitchAnimation(AnimationPlayerNode, "Idle")
	else:
		if Motion.y < 0.0:
			SwitchAnimation(AnimationPlayerNode, "Jump")
		elif Motion.y > 0.0:
			SwitchAnimation(AnimationPlayerNode, "Fall")
	
	if isOnFloor:
		CoyoteTime = 0.1
	else:
		CoyoteTime -= delta

func SwitchAnimation(animationPlayer, animation):
	if animation == "Walk" and not CarriesPresent:
		animation = "Run"
	if animationPlayer.current_animation != animation:
		animationPlayer.play(animation)

func _on_PresentDetector_body_entered(body):
	if not CarriesPresent and not body.Falling:
		CarriesPresent = true
		Present = body
		body.PickUp(self)
		Global.ReparentNode(body, PresentNode)

func _on_PresentDetector_area_entered(area):
	pass

func _input(event):
	if event.is_action_pressed("ui_down"):
		if CarriesPresent:
			CarriesPresent = false
			Present.Fall(SpriteNode.scale * -100.0)
			Global.ReparentNode(Present, get_tree().root)
			Present.set_position(PresentNode.get_global_position())
