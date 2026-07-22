extends SceneTree
func _init():
    var Child = load("res://child.gd")
    var child = Child.new()
    root.add_child(child)
    quit()
