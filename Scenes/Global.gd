extends Node

func ReparentNode(child, newParent):
	var oldParent = child.get_parent()
	oldParent.call_deferred("remove_child", child)
	newParent.call_deferred("add_child", child)
