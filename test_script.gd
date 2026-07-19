extends SceneTree
func _init():
	var res = preload("res://data/stat.gd").new()
	var props = res.get_script().get_script_property_list()
	for p in props:
		print(p.name)
	quit()
