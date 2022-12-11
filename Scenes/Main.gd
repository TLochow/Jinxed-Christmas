extends Node2D

var PRESENTPLATFORMSCENE = preload("res://Scenes/PresentPlatform.tscn")

func _ready():
	randomize()
	
	var platformsNode = $PresentPlatforms
	for i in range(22):
		var platform = PRESENTPLATFORMSCENE.instance()
		platform.MoveOffset = i * 32.0
		platformsNode.add_child(platform)
