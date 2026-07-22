extends SceneTree
class BaseClass extends Node:
    var arr = []
    func _ready():
        print("Base _ready")
        arr.resize(11)
        
class ChildClass extends BaseClass:
    func _ready():
        print("Child _ready")
        print("arr size in child: ", arr.size())
        
func _init():
    var child = ChildClass.new()
    root.add_child(child)
    quit()
