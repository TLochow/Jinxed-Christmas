extends CanvasLayer

onready var AnimPlayer = $AnimationPlayer

func _ready():
	AnimPlayer.play("FadeIn")

func ChangeScene(path):
	AnimPlayer.play("FadeOut")
	yield(AnimPlayer, "animation_finished")
	var _result = get_tree().change_scene(path)
	AnimPlayer.play("FadeIn")

func EndGame():
	AnimPlayer.play("FadeOut")
	yield(AnimPlayer, "animation_finished")
	get_tree().quit()
